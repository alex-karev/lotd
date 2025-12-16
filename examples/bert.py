import torch
from transformers import AutoTokenizer
from src.lotd import generate_chat_template, datasets

"""
Fine-tunes distilbert-base-uncased with instruction prompt from Alpaca by randomly masking tokens from assistant response
"""


# Post collator for masking
def post_collator(tokenizer):
    mask_id = tokenizer.mask_token_id

    def collate(batch):
        # Clone input_ids
        targets = batch["input_ids"].clone()
        # Define masking probabilities
        mask_rate = torch.rand(targets.shape[:-1])
        batch["mask_rate"] = mask_rate
        mask_rate = mask_rate.unsqueeze(1).expand(-1, targets.shape[-1])
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

    # Add new chat template to distilbert-base-uncased (no chat template by default)
    chat_template = generate_chat_template()
    tokenizer.chat_template = chat_template
    print(f"Chat template:\n{chat_template}\n")

    # Load alpaca dataset
    train, val, test = datasets.alpaca(
        tokenizer,
        cache_path="cached_dataset",
        post=post_collator(tokenizer),
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
        print("Mask rate:", batch["mask_rate"][0].item())
        # Do not loop over all batches
        break
