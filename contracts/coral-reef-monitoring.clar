;; Coral Reef Monitoring Contract
;; Tracks ecosystem health indicators and restoration efforts

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u400))
(define-constant ERR_REEF_NOT_FOUND (err u401))
(define-constant ERR_INVALID_METRICS (err u402))
(define-constant ERR_INVALID_LOCATION (err u403))
(define-constant ERR_MEASUREMENT_NOT_FOUND (err u404))

;; Data Variables
(define-data-var next-measurement-id uint u1)
(define-data-var next-project-id uint u1)

;; Data Maps
(define-map reef-locations
  (string-ascii 50)
  {
    coordinates: (string-ascii 100),
    size: uint,
    depth: uint,
    established: uint,
    status: (string-ascii 20)
  }
)

(define-map health-measurements
  uint
  {
    reef-location: (string-ascii 50),
    temperature: uint,
    ph-level: uint,
    bleaching-percentage: uint,
    coral-coverage: uint,
    fish-diversity: uint,
    measurer: principal,
    timestamp: uint
  }
)

(define-map restoration-projects
  uint
  {
    reef-location: (string-ascii 50),
    project-type: (string-ascii 50),
    start-date: uint,
    end-date: uint,
    budget: uint,
    status: (string-ascii 20),
    coordinator: principal
  }
)

(define-map authorized-researchers principal bool)

;; Authorization Functions
(define-public (add-researcher (researcher principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (map-set authorized-researchers researcher true))
  )
)

(define-public (remove-researcher (researcher principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (map-delete authorized-researchers researcher))
  )
)

;; Reef Management
(define-public (register-reef (location (string-ascii 50)) (coordinates (string-ascii 100)) (size uint) (depth uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (> (len location) u0) ERR_INVALID_LOCATION)
    (asserts! (> size u0) ERR_INVALID_METRICS)
    (ok (map-set reef-locations location {
      coordinates: coordinates,
      size: size,
      depth: depth,
      established: block-height,
      status: "active"
    }))
  )
)

(define-public (update-reef-status (location (string-ascii 50)) (new-status (string-ascii 20)))
  (let (
    (reef-data (map-get? reef-locations location))
  )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (match reef-data
      reef
      (ok (map-set reef-locations location
        (merge reef { status: new-status })
      ))
      ERR_REEF_NOT_FOUND
    )
  )
)

;; Health Monitoring
(define-public (record-measurement (reef-location (string-ascii 50)) (temperature uint) (ph-level uint) (bleaching-percentage uint) (coral-coverage uint) (fish-diversity uint))
  (let (
    (measurement-id (var-get next-measurement-id))
    (is-authorized (default-to false (map-get? authorized-researchers tx-sender)))
    (reef-exists (is-some (map-get? reef-locations reef-location)))
  )
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) is-authorized) ERR_UNAUTHORIZED)
    (asserts! reef-exists ERR_REEF_NOT_FOUND)
    (asserts! (<= bleaching-percentage u100) ERR_INVALID_METRICS)
    (asserts! (<= coral-coverage u100) ERR_INVALID_METRICS)

    (map-set health-measurements measurement-id {
      reef-location: reef-location,
      temperature: temperature,
      ph-level: ph-level,
      bleaching-percentage: bleaching-percentage,
      coral-coverage: coral-coverage,
      fish-diversity: fish-diversity,
      measurer: tx-sender,
      timestamp: block-height
    })

    (var-set next-measurement-id (+ measurement-id u1))
    (try! (assess-reef-health reef-location bleaching-percentage coral-coverage))
    (ok measurement-id)
  )
)

(define-private (assess-reef-health (location (string-ascii 50)) (bleaching uint) (coverage uint))
  (let (
    (reef-data (map-get? reef-locations location))
    (health-status (if (or (> bleaching u50) (< coverage u30)) "critical"
                      (if (or (> bleaching u25) (< coverage u50)) "poor" "good")))
  )
    (match reef-data
      reef
      (ok (map-set reef-locations location
        (merge reef { status: health-status })
      ))
      ERR_REEF_NOT_FOUND
    )
  )
)

;; Restoration Projects
(define-public (create-restoration-project (reef-location (string-ascii 50)) (project-type (string-ascii 50)) (end-date uint) (budget uint))
  (let (
    (project-id (var-get next-project-id))
    (reef-exists (is-some (map-get? reef-locations reef-location)))
  )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! reef-exists ERR_REEF_NOT_FOUND)
    (asserts! (> budget u0) ERR_INVALID_METRICS)

    (map-set restoration-projects project-id {
      reef-location: reef-location,
      project-type: project-type,
      start-date: block-height,
      end-date: end-date,
      budget: budget,
      status: "planning",
      coordinator: tx-sender
    })

    (var-set next-project-id (+ project-id u1))
    (ok project-id)
  )
)

(define-public (update-project-status (project-id uint) (new-status (string-ascii 20)))
  (let (
    (project-data (map-get? restoration-projects project-id))
  )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (match project-data
      project
      (ok (map-set restoration-projects project-id
        (merge project { status: new-status })
      ))
      ERR_REEF_NOT_FOUND
    )
  )
)

;; Read-only Functions
(define-read-only (get-reef-info (location (string-ascii 50)))
  (map-get? reef-locations location)
)

(define-read-only (get-measurement (measurement-id uint))
  (map-get? health-measurements measurement-id)
)

(define-read-only (get-restoration-project (project-id uint))
  (map-get? restoration-projects project-id)
)

(define-read-only (is-researcher-authorized (researcher principal))
  (default-to false (map-get? authorized-researchers researcher))
)

(define-read-only (get-next-measurement-id)
  (var-get next-measurement-id)
)

(define-read-only (get-next-project-id)
  (var-get next-project-id)
)
