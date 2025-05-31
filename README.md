# WellnessTracker

A decentralized wellness tracking platform that incentivizes healthy lifestyle choices and rewards consistent wellness activities through blockchain-based point systems.

## Overview

WellnessTracker is a smart contract platform that enables individuals to track their wellness activities and earn points based on their commitment to healthy living. The system includes features for tracking activity streaks, committing points for long-term wellness goals, and managing a sustainable wellness economy.

## Features

- **Activity Tracking**: Record and validate wellness activities and exercises
- **Streak Bonuses**: Reward participants who maintain regular wellness routines
- **Point Redemption**: Allow participants to redeem earned wellness points
- **Point Commitment**: Enable participants to commit points for long-term wellness goals
- **Wellness Statistics**: Track overall activity metrics and point distribution

## Core Functions

- `begin-wellness-activity`: Start tracking a new wellness activity session
- `complete-wellness-activity`: Finalize an activity and receive wellness points
- `claim-wellness-rewards`: Exchange accumulated points for wellness benefits
- `commit-wellness-points`: Commit points for long-term wellness goals
- `withdraw-committed-points`: Retrieve committed points (with potential penalties for early withdrawal)

## Technical Details

- Maximum wellness pool capacity: 2,000,000 points
- Base activity reward: 15 points
- Streak bonus: 3 points per level (up to 10 levels)
- Minimum commitment duration: 432 blocks (approximately 3 days)
- Early withdrawal penalty: 15%

## Getting Started

1. Deploy the contract to your blockchain
2. Participants can start tracking their wellness activities
3. Complete activities to earn wellness points
4. Commit points for long-term wellness goals
5. Redeem points for wellness benefits when ready

## Security

The system includes safeguards to prevent exceeding the wellness pool capacity and ensures that only legitimate activities are rewarded.