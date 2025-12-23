import torch
from transformers import AutoTokenizer
from lotd import datasets

"""
Fine-tunes distilbert-base-uncased on TinyStories dataset with 30% masking rate.
"""

# Post collator for masking
def post_collator(tokenizer, mask_rate: float = 0.3):
    mask_id = tokenizer.mask_token_id

    def collate(batch):
        # Clone input_ids
        targets = batch["input_ids"].clone()
        # Define masking probabilities
        probs = torch.rand_like(targets, dtype=torch.float)
        # Mask non-prompt tokens
        mask = (probs < mask_rate) & (batch["prompt_mask"] == 0)
        batch["input_ids"][mask] = mask_id
        # Set all unmask targets to -100
        targets[~mask] = -100
        batch["targets"] = targets
        # Return modified batch data
        return batch

    return collate


# Run script
if __name__ == "__main__":
    # Define tokenizer
    tokenizer = AutoTokenizer.from_pretrained("distilbert-base-uncased")

    # Load tinystories dataset
    train, val, test = datasets.tinystories(
        tokenizer,
        cache_path="cached_dataset",
        template="[CLS]{{text}}[SEP]",
        post=post_collator(tokenizer, 0.3),
        batch_size=16,
        max_length=512,
    )

    # Print the first sample of the first batch
    for batch in train:
        input_ids = tokenizer.decode(
            batch["input_ids"][0], skip_special_tokens=False
        ).replace(" [PAD]", "")
        target = ", ".join(
            [tokenizer.decode(x) for x in batch["targets"][0].tolist() if x != -100]
        )
        attention_mask = " ".join([str(x) for x in batch["attention_mask"][0].tolist()])
        prompt_mask = " ".join([str(x) for x in batch["prompt_mask"][0].tolist()])
        # Print data
        print("Input:", input_ids)
        print("Target:", target)
        print("Attention mask:", attention_mask)
        print("Prompt mask:", prompt_mask)
        # Do not loop over all batches
        break
