library(torch)
library(torchvision)
library(torchdatasets)
library(luz)


# Data --------------------------------------------------------------------

usethis::use_directory(here::here("data"))

ds <- torchdatasets::dogs_vs_cats_dataset(
  root = "data",
  token = "~/.kaggle/kaggle.json",
  transform = . %>%
    torchvision::transform_to_tensor() %>%
    torchvision::transform_resize(size = c(224, 224)) %>%
    torchvision::transform_normalize(rep(0.5, 3), rep(0.5, 3)),
  target_transform = function(x) as.double(x) - 1
)

train_ids <- sample(1:length(ds), size = 0.6 * length(ds))
valid_ids <- sample(setdiff(1:length(ds), train_ids), size = 0.2 * length(ds))
test_ids <- setdiff(1:length(ds), union(train_ids, valid_ids))

train_ds <- dataset_subset(ds, indices = train_ids)
valid_ds <- dataset_subset(ds, indices = valid_ids)
test_ds <- dataset_subset(ds, indices = test_ids)

train_dl <- dataloader(train_ds, batch_size = 64, shuffle = TRUE, num_workers = 4)
valid_dl <- dataloader(valid_ds, batch_size = 64, num_workers = 4)
test_dl <- dataloader(test_ds, batch_size = 64, num_workers = 4)


# Model -------------------------------------------------------------------

net <- torch::nn_module(

  initialize = function(output_size) {
    # Uses a predefined model as a basis!
    self$model <- model_alexnet(pretrained = TRUE)

    for (par in self$parameters) {
      par$requires_grad_(FALSE)
    }

    self$model$classifier <- nn_sequential(
      nn_dropout(0.5),
      nn_linear(9216, 512),
      nn_relu(),
      nn_linear(512, 256),
      nn_relu(),
      nn_linear(256, output_size)
    )
  },
  forward = function(x) {
    self$model(x)[,1]
  }

)


# Training ----------------------------------------------------------------

fitted <- net %>%
  setup(
    loss = nn_bce_with_logits_loss(),
    optimizer = optim_adam,
    metrics = list(
      luz_metric_binary_accuracy_with_logits()
    )
  ) %>%
  set_hparams(output_size = 1) %>%
  set_opt_hparams(lr = 0.01) %>%
  fit(train_dl, epochs = 3, valid_data = valid_dl)

# Optional saving
luz_save(fitted, "dogs-and-cats.pt")


# Predict -----------------------------------------------------------------

preds <- predict(fitted, test_dl)

probs <- torch_sigmoid(preds)
print(probs, n = 5)
