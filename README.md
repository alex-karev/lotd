# LOTD - Lord Of The Datasets

Efficient NLP dataset preprocessing library for instruction tuning and general NLP tasks.

## Features

- Chat and text tokenization
- Length filtering
- Padding collators
- HuggingFace dataset utilities (splitting, caching, dataloaders)
- Prebuilt Alpaca dataset loader

## Documentation

This package provides MkDocs [documentaion](https://alex-karev.github.io/lotd/).

## Installation

```bash
pip install lotd
```

> WARNING: Not available in pip yet

## Example Usage

```python
from lotd import ChatTokenizer, PadCollator, get_loaders, datasets

# Initialize tokenizer
chat_tokenizer = ChatTokenizer(tokenizer=my_pretrained_tokenizer)

# Preprocess dataset
dataset = my_dataset.map(lambda x: chat_tokenizer(x['prompt'], x['response']))

# Filter by length
filter = LengthFilter(min_length=10, max_length=512)
dataset = dataset.filter(lambda x: filter(x['input_ids']))

# Create DataLoader
collator = PadCollator(pad_id=0)
train_loader, val_loader, test_loader = get_loaders(dataset, collate_fn=collator)
```

## Prebuilt Datasets

```python
from lotd.datasets import alpaca
train_loader, val_loader, test_loader = alpaca(tokenizer=my_tokenizer)
```

## Build

1. Clone this repo:

```bash
git clone https://github.com/alex-karev/lotd.git
cd lotd
```

2. Install build tools:

```bash
pip install --upgrade build setuptools wheel
```

3. Build package:

```bash
python -m build
```

4. Install:

```bash
pip install dist/lotd-0.1.0-py3-none-any.whl
```

## Nix

You can include LOTD in another project with Nix Flakes:

```nix
{
  description = "My NLP Project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    lotd.url = "github:alex-karev/lotd"; # LOTD flake
  };

  outputs = { self, nixpkgs, lotd }: let
    pkgs = import nixpkgs { system = "x86_64-linux"; };
    pythonDeps = pkgs.python312.withPackages (p: [
      lotd.packages.x86_64-linux.lotd
      # other python deps
    ]);
  in {
    devShells.default = pkgs.mkShell {
      name = "my-nlp-project";
      packages = [ pythonDeps ];
    };
  };
}
```

## License

See `LICENSE`
