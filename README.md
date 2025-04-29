# Social Network Analysis of Government Websites

This project explores the hyperlink structure of government websites using social network analysis (SNA). Each government website is represented as a node, and hyperlinks between sites are modeled as directed edges. The resulting network graph is used to analyze the interconnectivity and structure of the digital public sector.

## Features

- 🌐 **Web Graph Construction**: Builds a directed graph from hyperlinks among government websites.
- 🔍 **Breadth-First Traversal**: Extracts data using BFS to capture relevant and reachable nodes.
- 📊 **Social Network Metrics**: Applies centrality and connectivity measures using `igraph`.
- 🖼️ **Visualization**: Includes a graphical representation of the resulting network.
- 📁 **Reproducible Workflow**: Code and data included for replicating the analysis in R.

## Getting Started

### Prerequisites

Make sure you have the following installed:

- **R** (version 3.6 or newer)
- R packages:
  - `igraph`
  - `readr`
  - `ggplot2` (optional, for further visualization)

### Installation & Setup

1. Clone this repository:

   ```bash
   git clone https://github.com/casualcomputer/social-network-analysis.git
   cd social-network-analysis
   ```

2. Open the `website_network.R` file in RStudio or your preferred R IDE.

3. Install required packages (if not already installed):

   ```r
   install.packages(c("igraph", "readr", "ggplot2"))
   ```

4. Run the script:

   ```r
   source("website_network.R")
   ```

## Repository Structure

| File                        | Description                                                  |
| --------------------------- | ------------------------------------------------------------ |
| `website_network.R`         | Core script to construct the graph and analyze the network.  |
| `hyperlinkTraversal.csv`    | Input data containing hyperlink relationships between sites. |
| `social_network_normal.PNG` | Visualization of the resulting network.                      |
| `README.md`                 | This file.                                                   |

## Business-Oriented Analysis Objectives

- **How do people typically navigate CRA websites to find information?**  
  Identify common user paths through the CRA web ecosystem using hyperlink traversal analysis. This helps improve access to frequently asked information.

- **Which CRA websites are the most important or influential?**  
  Determine key content hubs using network centrality measures to prioritize updates and resource focus.

- **Is the CRA’s website network well-connected or fragmented?**  
  Analyze the overall structure to identify isolated groups of pages and enhance internal linking where needed.

- **What does the web structure reveal about how CRA sites are organized?**  
  Use metrics like link distribution and cluster size to assess and optimize the navigation experience.

## License

This project is licensed under the [GNU GPL-3.0 License](LICENSE).

## Author

Developed by [@casualcomputer](https://github.com/casualcomputer). Contributions and suggestions welcome!
