# Tokenized Ocean Conservation Management System

A comprehensive blockchain-based system for managing ocean conservation efforts using Clarity smart contracts on the Stacks blockchain.

## System Overview

This system consists of five interconnected contracts that work together to manage various aspects of ocean conservation:

1. **Marine Life Tracking Contract** - Monitors endangered species populations
2. **Pollution Detection Contract** - Identifies ocean contamination sources
3. **Fishing Quota Contract** - Manages sustainable catch limits
4. **Coral Reef Monitoring Contract** - Tracks ecosystem health indicators
5. **Cleanup Coordination Contract** - Organizes ocean waste removal efforts

## Features

### Marine Life Tracking
- Track endangered species populations by location
- Record sighting data with timestamps
- Monitor population trends over time
- Issue conservation alerts when populations drop below thresholds

### Pollution Detection
- Log pollution incidents with severity levels
- Track contamination sources and types
- Maintain cleanup status for each incident
- Generate pollution reports by region

### Fishing Quota Management
- Set sustainable catch limits by species and region
- Track fishing activities and quota usage
- Enforce quota limits through smart contract logic
- Monitor compliance and issue violations

### Coral Reef Monitoring
- Record reef health metrics (temperature, pH, bleaching)
- Track ecosystem indicators over time
- Issue health alerts for declining reefs
- Maintain restoration project records

### Cleanup Coordination
- Organize ocean waste removal efforts
- Track cleanup events and participation
- Reward participants with conservation tokens
- Monitor waste collection metrics

## Contract Architecture

Each contract is designed to be independent while sharing common data structures and patterns:

- **Data Storage**: Uses Clarity maps for efficient data retrieval
- **Access Control**: Role-based permissions for different user types
- **Event Logging**: Comprehensive logging for all major actions
- **Error Handling**: Descriptive error codes for debugging
- **Token Integration**: Conservation tokens for incentivizing participation

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Basic understanding of Clarity smart contracts
- Node.js for running tests

### Installation

1. Clone the repository
2. Install dependencies: \`npm install\`
3. Run tests: \`npm test\`
4. Deploy contracts: \`clarinet deploy\`

### Testing

The system includes comprehensive tests using Vitest:

\`\`\`bash
npm test
\`\`\`

Tests cover:
- Contract deployment and initialization
- Core functionality for each contract
- Error handling and edge cases
- Integration between contracts
- Token economics and rewards

## Usage Examples

### Recording Marine Life Sighting
\`\`\`clarity
(contract-call? .marine-life-tracking record-sighting
"whale"
"pacific-north"
u50
"healthy-population")
\`\`\`

### Reporting Pollution Incident
\`\`\`clarity
(contract-call? .pollution-detection report-incident
"oil-spill"
"atlantic-coast"
u8
"tanker-accident")
\`\`\`

### Setting Fishing Quota
\`\`\`clarity
(contract-call? .fishing-quota set-quota
"tuna"
"mediterranean"
u1000)
\`\`\`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or support, please open an issue on GitHub.
