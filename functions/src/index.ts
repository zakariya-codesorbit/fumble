import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2";
import { randomBytes } from "crypto";

admin.initializeApp();
setGlobalOptions({ region: "us-central1" });

const db = admin.firestore();

function requireAuth(request: { auth?: { uid: string } }): string {
  if (!request.auth?.uid) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  return request.auth.uid;
}

function newFlumbleCode(): string {
  return randomBytes(6).toString("hex").toUpperCase();
}

/**
 * Validate a FLUMBLE code and open a short-lived exchange session.
 * Returns only minimal preview fields.
 */
export const resolveFumble = onCall(
  { enforceAppCheck: false },
  async (request) => {
    const scannerUid = requireAuth(request);
    const flumbleCode = String(request.data?.flumbleCode ?? "")
      .trim()
      .toUpperCase();

    if (!/^[A-Z0-9]{8,32}$/.test(flumbleCode)) {
      throw new HttpsError("invalid-argument", "Invalid FLUMBLE code.");
    }

    const usersSnap = await db
      .collection("users")
      .where("flumbleCode", "==", flumbleCode)
      .limit(1)
      .get();

    if (usersSnap.empty) {
      throw new HttpsError("not-found", "FLUMBLE code not found.");
    }

    const ownerDoc = usersSnap.docs[0];
    const ownerUid = ownerDoc.id;
    const owner = ownerDoc.data();

    if (ownerUid === scannerUid) {
      throw new HttpsError("failed-precondition", "You can't fumble yourself.");
    }

    // Idempotent duplicate check (either direction).
    const existing = await db
      .collection("users")
      .doc(scannerUid)
      .collection("connections")
      .doc(ownerUid)
      .get();
    if (existing.exists) {
      throw new HttpsError("already-exists", "You're already connected.");
    }

    const sessionRef = db.collection("sessions").doc();
    const now = admin.firestore.Timestamp.now();
    const expiresAt = admin.firestore.Timestamp.fromMillis(
      now.toMillis() + 10 * 60 * 1000
    );

    await sessionRef.set({
      scannerUid,
      ownerUid,
      status: "pending",
      createdAt: now,
      expiresAt,
    });

    return {
      sessionId: sessionRef.id,
      peerUid: ownerUid,
      name: String(owner.name ?? ""),
      email: String(owner.email ?? ""),
      photoUrl: owner.photoUrl ?? null,
    };
  }
);

/**
 * Atomically create both connection cards for a validated session.
 */
export const completeFumble = onCall(
  { enforceAppCheck: false },
  async (request) => {
    const scannerUid = requireAuth(request);
    const sessionId = String(request.data?.sessionId ?? "").trim();
    if (!sessionId) {
      throw new HttpsError("invalid-argument", "sessionId is required.");
    }

    const sessionRef = db.collection("sessions").doc(sessionId);

    await db.runTransaction(async (tx) => {
      const sessionSnap = await tx.get(sessionRef);
      if (!sessionSnap.exists) {
        throw new HttpsError("not-found", "Session not found.");
      }
      const session = sessionSnap.data()!;
      if (session.scannerUid !== scannerUid) {
        throw new HttpsError("permission-denied", "Not your session.");
      }
      if (session.status === "completed") {
        return; // idempotent
      }
      if (session.status !== "pending") {
        throw new HttpsError("failed-precondition", "Session is not pending.");
      }
      const expiresAt = session.expiresAt as admin.firestore.Timestamp;
      if (expiresAt.toMillis() < Date.now()) {
        tx.update(sessionRef, { status: "expired" });
        throw new HttpsError("failed-precondition", "Session expired.");
      }

      const ownerUid = String(session.ownerUid);
      const scannerUserRef = db.collection("users").doc(scannerUid);
      const ownerUserRef = db.collection("users").doc(ownerUid);

      const [scannerSnap, ownerSnap] = await Promise.all([
        tx.get(scannerUserRef),
        tx.get(ownerUserRef),
      ]);

      if (!scannerSnap.exists || !ownerSnap.exists) {
        throw new HttpsError("not-found", "User profile missing.");
      }

      const scanner = scannerSnap.data()!;
      const owner = ownerSnap.data()!;
      const fumbledAt = admin.firestore.FieldValue.serverTimestamp();

      const scannerConnectionRef = scannerUserRef
        .collection("connections")
        .doc(ownerUid);
      const ownerConnectionRef = ownerUserRef
        .collection("connections")
        .doc(scannerUid);

      tx.set(
        scannerConnectionRef,
        {
          peerUid: ownerUid,
          name: String(owner.name ?? ""),
          email: String(owner.email ?? ""),
          photoUrl: owner.photoUrl ?? null,
          fumbledAt,
        },
        { merge: true }
      );

      tx.set(
        ownerConnectionRef,
        {
          peerUid: scannerUid,
          name: String(scanner.name ?? ""),
          email: String(scanner.email ?? ""),
          photoUrl: scanner.photoUrl ?? null,
          fumbledAt,
        },
        { merge: true }
      );

      tx.update(sessionRef, {
        status: "completed",
        completedAt: fumbledAt,
      });
    });

    // Best-effort push to the owner.
    try {
      const sessionSnap = await sessionRef.get();
      const ownerUid = String(sessionSnap.data()?.ownerUid ?? "");
      const ownerDoc = await db.collection("users").doc(ownerUid).get();
      const token = ownerDoc.data()?.fcmToken as string | undefined;
      const scannerDoc = await db.collection("users").doc(scannerUid).get();
      const scannerName = String(scannerDoc.data()?.name ?? "Someone");
      if (token) {
        await admin.messaging().send({
          token,
          notification: {
            title: "New FLUMBLE",
            body: `${scannerName} fumbled you.`,
          },
          data: {
            type: "fumble_completed",
            peerUid: scannerUid,
          },
        });
      }
    } catch (e) {
      console.warn("FCM notify failed", e);
    }

    return { ok: true };
  }
);

/**
 * Rotate the caller's FLUMBLE identity code.
 */
export const rotateFumbleCode = onCall(
  { enforceAppCheck: false },
  async (request) => {
    const uid = requireAuth(request);
    const code = newFlumbleCode();
    await db.collection("users").doc(uid).update({
      flumbleCode: code,
      lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { flumbleCode: code };
  }
);
