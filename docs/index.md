# LOTD - Lord Of The Datasets

LOTD (Lord Of The Datasets) is an efficient and flexible NLP dataset preprocessing library designed to simplify working with large-scale text datasets. Its goal is to make dataset preparation, filtering, tokenization, and batching seamless for research.

---

## Motivation

Preparing NLP datasets for model training can be tedious and error-prone. Tasks such as:

- Tokenizing text or chat dialogs
- Applying templates for instruction tuning
- Filtering sequences by length
- Padding and batching for PyTorch

often require custom scripts that are hard to maintain and reuse. LOTD aims to solve this by providing **reusable building blocks** and **ready-to-use utilities**, so developers and researchers can focus on modeling instead of boilerplate preprocessing.

---

## Features Overview

LOTD provides:

- **Flexible tokenizers** for text and chat datasets, including support for system, user, and assistant roles.
- **Collators and filters** that handle padding, batching, and sequence length constraints efficiently.
- **Dataset utilities** for splitting, caching, and creating PyTorch DataLoaders from HuggingFace datasets.
- **Prebuilt loaders** for popular datasets such as Alpaca, ready for instruction fine-tuning.

---

LOTD is designed to **reduce boilerplate**, **improve reproducibility**, and **make dataset preprocessing more intuitive**, so you can spend more time experimenting with models and less time writing tedious preprocessing code.

