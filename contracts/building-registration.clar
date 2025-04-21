;; building-registration.clar
;; Records details of commercial structures

(define-data-var last-building-id uint u0)

(define-map buildings
  { building-id: uint }
  {
    owner: principal,
    name: (string-utf8 100),
    address: (string-utf8 200),
    floors: uint,
    registration-date: uint,
    active: bool
  }
)

(define-public (register-building (name (string-utf8 100)) (address (string-utf8 200)) (floors uint))
  (let
    (
      (new-id (+ (var-get last-building-id) u1))
    )
    (var-set last-building-id new-id)
    (map-set buildings
      { building-id: new-id }
      {
        owner: tx-sender,
        name: name,
        address: address,
        floors: floors,
        registration-date: block-height,
        active: true
      }
    )
    (ok new-id)
  )
)

(define-read-only (get-building (building-id uint))
  (map-get? buildings { building-id: building-id })
)

(define-read-only (get-building-count)
  (var-get last-building-id)
)

(define-public (update-building-status (building-id uint) (active bool))
  (let
    (
      (building (unwrap! (map-get? buildings { building-id: building-id }) (err u1)))
    )
    (asserts! (is-eq tx-sender (get owner building)) (err u2))
    (map-set buildings
      { building-id: building-id }
      (merge building { active: active })
    )
    (ok true)
  )
)
