---
name: Customer routing decision
description: CUSTOMER role always routes to livestockFarmerHome — by design, not a bug
type: project
---

CUSTOMER role always routes to `Routes.livestockFarmerHome` in `SplashViewModel._checkSession`.

**Why:** CUSTOMERs cannot have a `partnerType`. The pet-owner flow (`Routes.homeCustomerPet`) is only for ASSOCIATE users with a pet-related `partnerType`. The CUSTOMER role is exclusively used for livestock farmers.

**How to apply:** Do not flag this routing as a bug. Do not suggest adding `partnerType` logic for the CUSTOMER role.
