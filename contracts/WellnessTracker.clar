;; Constants
(define-constant WELLNESS_POOL_CAPACITY u2000000)
(define-constant BASE_ACTIVITY_REWARD u15)
(define-constant STREAK_BONUS u3)
(define-constant MAX_STREAK_LEVEL u10)
(define-constant ERR_INVALID_ACTIVITY u1)
(define-constant ERR_NO_WELLNESS_POINTS u2)
(define-constant ERR_POOL_EXCEEDED u3)
(define-constant BLOCKS_PER_WEEK u1008)
(define-constant COMMITMENT_MULTIPLIER u3)
(define-constant MIN_COMMITMENT_DURATION u432)
(define-constant EARLY_WITHDRAWAL_PENALTY u15)

;; Data Variables
(define-data-var total-wellness-points-issued uint u0)
(define-data-var total-activities uint u0)
(define-data-var wellness-coordinator principal tx-sender)

;; Data Maps
(define-map participant-activities principal uint)
(define-map participant-wellness-points principal uint)
(define-map activity-start-time principal uint)
(define-map participant-streak principal uint)
(define-map participant-last-check-in principal uint)
(define-map participant-committed-points principal uint)
(define-map participant-commitment-start-block principal uint)

;; Public Functions

(define-public (begin-wellness-activity (intensity uint))
  (let
    (
      (participant tx-sender)
    )
    (asserts! (> intensity u0) (err ERR_INVALID_ACTIVITY))
    (map-set activity-start-time participant burn-block-height)
    (ok true)
  )
)

(define-public (complete-wellness-activity (intensity uint))
  (let
    (
      (participant tx-sender)
      (start-block (default-to u0 (map-get? activity-start-time participant)))
      (blocks-elapsed (- burn-block-height start-block))
      (last-check-in-block (default-to u0 (map-get? participant-last-check-in participant)))
      (streak-level (default-to u0 (map-get? participant-streak participant)))
      (capped-streak (if (<= streak-level MAX_STREAK_LEVEL) streak-level MAX_STREAK_LEVEL))
      (reward-amount (+ BASE_ACTIVITY_REWARD (* capped-streak STREAK_BONUS)))
    )
    (asserts! (and (> start-block u0) (>= blocks-elapsed intensity)) (err ERR_INVALID_ACTIVITY))
    (map-set participant-activities participant (+ (default-to u0 (map-get? participant-activities participant)) u1))
    (map-set participant-wellness-points participant (+ (default-to u0 (map-get? participant-wellness-points participant)) reward-amount))
    (if (< (- burn-block-height last-check-in-block) BLOCKS_PER_WEEK)
      (map-set participant-streak participant (+ streak-level u1))
      (map-set participant-streak participant u1)
    )
    (map-set participant-last-check-in participant burn-block-height)
    (var-set total-activities (+ (var-get total-activities) u1))
    (var-set total-wellness-points-issued (+ (var-get total-wellness-points-issued) reward-amount))
    (asserts! (<= (var-get total-wellness-points-issued) WELLNESS_POOL_CAPACITY) (err ERR_POOL_EXCEEDED))
    (ok reward-amount)
  )
)

(define-public (claim-wellness-rewards)
  (let
    (
      (participant tx-sender)
      (point-balance (default-to u0 (map-get? participant-wellness-points participant)))
    )
    (asserts! (> point-balance u0) (err ERR_NO_WELLNESS_POINTS))
    (map-set participant-wellness-points participant u0)
    (ok point-balance)
  )
)

;; Commitment Features

(define-public (commit-wellness-points (amount uint))
  (let
    (
      (participant tx-sender)
    )
    (asserts! (> amount u0) (err ERR_INVALID_ACTIVITY))
    (asserts! (>= (var-get total-wellness-points-issued) amount) (err ERR_POOL_EXCEEDED))
    (map-set participant-committed-points participant amount)
    (map-set participant-commitment-start-block participant burn-block-height)
    (var-set total-wellness-points-issued (- (var-get total-wellness-points-issued) amount))
    (ok amount)
  )
)

(define-public (withdraw-committed-points)
  (let
    (
      (participant tx-sender)
      (committed-amount (default-to u0 (map-get? participant-committed-points participant)))
      (commitment-start-block (default-to u0 (map-get? participant-commitment-start-block participant)))
      (blocks-committed (- burn-block-height commitment-start-block))
      (penalty (if (< blocks-committed MIN_COMMITMENT_DURATION) (/ (* committed-amount EARLY_WITHDRAWAL_PENALTY) u100) u0))
      (final-amount (- committed-amount penalty))
    )
    (asserts! (> committed-amount u0) (err ERR_NO_WELLNESS_POINTS))
    (map-set participant-committed-points participant u0)
    (map-set participant-commitment-start-block participant u0)
    (var-set total-wellness-points-issued (+ (var-get total-wellness-points-issued) final-amount))
    (ok final-amount)
  )
)

;; Read-Only Functions

(define-read-only (get-activity-count (user principal))
  (default-to u0 (map-get? participant-activities user))
)

(define-read-only (get-wellness-point-balance (user principal))
  (default-to u0 (map-get? participant-wellness-points user))
)

(define-read-only (get-streak-level (user principal))
  (default-to u0 (map-get? participant-streak user))
)

(define-read-only (get-wellness-pool-stats)
  {
    total-activities: (var-get total-activities),
    total-wellness-points-issued: (var-get total-wellness-points-issued)
  }
)

;; Private Functions

(define-private (is-wellness-coordinator)
  (is-eq tx-sender (var-get wellness-coordinator))
)