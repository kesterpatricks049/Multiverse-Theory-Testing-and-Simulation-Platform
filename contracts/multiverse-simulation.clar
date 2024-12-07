;; multiverse-simulation contract

(define-data-var next-simulation-id uint u0)

(define-map simulations
  { simulation-id: uint }
  {
    creator: principal,
    parameters: (string-utf8 1024),
    hypothesis: (string-utf8 1024),
    status: (string-ascii 20),
    result: (optional (string-utf8 1024))
  }
)

(define-public (create-simulation (parameters (string-utf8 1024)) (hypothesis (string-utf8 1024)))
  (let
    (
      (simulation-id (var-get next-simulation-id))
    )
    (map-set simulations
      { simulation-id: simulation-id }
      {
        creator: tx-sender,
        parameters: parameters,
        hypothesis: hypothesis,
        status: "pending",
        result: none
      }
    )
    (var-set next-simulation-id (+ simulation-id u1))
    (ok simulation-id)
  )
)

(define-public (update-simulation-status (simulation-id uint) (new-status (string-ascii 20)))
  (let
    (
      (simulation (unwrap! (map-get? simulations { simulation-id: simulation-id }) (err u404)))
    )
    (asserts! (is-eq (get creator simulation) tx-sender) (err u403))
    (ok (map-set simulations
      { simulation-id: simulation-id }
      (merge simulation { status: new-status })
    ))
  )
)

(define-public (set-simulation-result (simulation-id uint) (result (string-utf8 1024)))
  (let
    (
      (simulation (unwrap! (map-get? simulations { simulation-id: simulation-id }) (err u404)))
    )
    (asserts! (is-eq (get creator simulation) tx-sender) (err u403))
    (ok (map-set simulations
      { simulation-id: simulation-id }
      (merge simulation { result: (some result), status: "completed" })
    ))
  )
)

(define-read-only (get-simulation (simulation-id uint))
  (map-get? simulations { simulation-id: simulation-id })
)

