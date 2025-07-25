;; Legendra Mystical Token Sanctuary
;; Description: Sanctuary response codes
(define-constant error-unauthorized-overlord (err u100))
(define-constant error-wrong-owner (err u101))
(define-constant error-no-listing (err u102))
(define-constant error-invalid-price (err u103))
(define-constant error-nonexistent-token (err u104))
(define-constant error-empty-heritage (err u105))
(define-constant error-price-too-high (err u106))

;; Dragon NFT
(define-non-fungible-token mythical-dragon uint)

;; Sanctuary management
(define-data-var supreme-overlord principal tx-sender)
(define-data-var dragon-counter uint u1)

;; Dragon chronicles
(define-map realm-chronicles
  { dragon-token: uint }
  { owner: principal, summoner: principal, heritage: (string-ascii 256), summon-price: uint })

;; Trading plaza
(define-map marketplace-listings
  { dragon-token: uint }
  { market-price: uint, seller: principal })

;; Authority check: overlord validation
(define-private (check-overlord)
  (is-eq tx-sender (var-get supreme-overlord)))

;; Crown new overlord
(define-public (crown-successor (new-ruler principal))
  (begin
    (asserts! (check-overlord) error-unauthorized-overlord)
    (asserts! (not (is-eq new-ruler (var-get supreme-overlord))) error-unauthorized-overlord)
    (asserts! (is-standard new-ruler) error-unauthorized-overlord)
    (ok (var-set supreme-overlord new-ruler))
  ))

;; Show overlord identity
(define-read-only (show-overlord)
  (ok (var-get supreme-overlord)))

;; Summon new dragon
(define-public (summon-dragon (heritage (string-ascii 256)) (summon-price uint))
  (let
    (
      (dragon-token (var-get dragon-counter))
    )
    (asserts! (> (len heritage) u0) error-empty-heritage)
    (asserts! (<= summon-price u1000) error-price-too-high)
    (try! (nft-mint? mythical-dragon dragon-token tx-sender))
    (map-set realm-chronicles
      { dragon-token: dragon-token }
      { owner: tx-sender, summoner: tx-sender, heritage: heritage, summon-price: summon-price }
    )
    (var-set dragon-counter (+ dragon-token u1))
    (ok dragon-token)
  ))

;; List dragon for sale
(define-public (list-for-sale (dragon-token uint) (market-price uint))
  (let
    (
      (current-owner (unwrap! (nft-get-owner? mythical-dragon dragon-token) error-nonexistent-token))
    )
    (asserts! (< dragon-token (var-get dragon-counter)) error-nonexistent-token)
    (asserts! (>= dragon-token u1) error-nonexistent-token)
    (asserts! (> market-price u0) error-invalid-price)
    (asserts! (is-eq tx-sender current-owner) error-wrong-owner)
    (map-set marketplace-listings
      { dragon-token: dragon-token }
      { market-price: market-price, seller: tx-sender }
    )
    (ok true)
  ))

;; Remove marketplace listing
(define-public (remove-listing (dragon-token uint))
  (let
    (
      (listing-info (unwrap! (map-get? marketplace-listings { dragon-token: dragon-token }) error-no-listing))
    )
    (asserts! (< dragon-token (var-get dragon-counter)) error-nonexistent-token)
    (asserts! (>= dragon-token u1) error-nonexistent-token)
    (asserts! (is-eq tx-sender (get seller listing-info)) error-wrong-owner)
    (map-delete marketplace-listings { dragon-token: dragon-token })
    (ok true)
  ))

;; Purchase mystical dragon
(define-public (purchase-dragon (dragon-token uint))
  (let
    (
      (trade-offer (unwrap! (map-get? marketplace-listings { dragon-token: dragon-token }) error-no-listing))
      (purchase-fee (get market-price trade-offer))
      (current-seller (get seller trade-offer))
      (dragon-records (unwrap! (map-get? realm-chronicles { dragon-token: dragon-token }) error-nonexistent-token))
    )
    (asserts! (< dragon-token (var-get dragon-counter)) error-nonexistent-token)
    (asserts! (>= dragon-token u1) error-nonexistent-token)
    (asserts! (not (is-eq tx-sender current-seller)) error-wrong-owner)
    (asserts! (is-eq current-seller (unwrap! (nft-get-owner? mythical-dragon dragon-token) error-nonexistent-token)) error-wrong-owner)
    (try! (stx-transfer? purchase-fee tx-sender current-seller))
    (try! (nft-transfer? mythical-dragon dragon-token current-seller tx-sender))
    (map-set realm-chronicles
      { dragon-token: dragon-token }
      { owner: tx-sender, summoner: (get summoner dragon-records), heritage: (get heritage dragon-records), summon-price: (get summon-price dragon-records) }
    )
    (map-delete marketplace-listings { dragon-token: dragon-token })
    (ok true)
  ))

;; View dragon details
(define-read-only (get-dragon-info (dragon-token uint))
  (map-get? realm-chronicles { dragon-token: dragon-token }))

;; View marketplace offer
(define-read-only (get-listing-info (dragon-token uint))
  (map-get? marketplace-listings { dragon-token: dragon-token }))

;; Get total dragons summoned
(define-read-only (get-total-dragons)
  (ok (- (var-get dragon-counter) u1)))
