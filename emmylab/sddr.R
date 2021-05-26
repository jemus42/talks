if (!requireNamespace('deepregression')) {
  remotes::install_github("davidruegamer/deepregression")
}

library(deepregression) # Will also install Python dependencies on first load
library(palmerpenguins) # For simple example data
penguins <- penguins %>%
  na.omit()

penguins_lm <- lm(bill_length_mm ~ bill_depth_mm + flipper_length_mm, data = penguins)

lof <- list(
  loc = ~ 1 + bill_depth_mm + deep(flipper_length_mm),
  scale = ~ 1
)

lod <- function(x) {
  x %>%
    layer_dense(units = 16, activation = "relu") %>%
    layer_dropout(rate = 0.2) %>%
    layer_dense(units = 1, activation = "linear")
}

penguins_sddr <- deepregression(
  y = penguins$bill_length_mm,
  data = penguins,
  list_of_formulae = lof,
  list_of_deep_models = list(deep = lod)
)

penguins_sddr

penguins_sddr %>%
  fit(
    epochs = 10,
    verbose = TRUE,
    validation_split = 0.2
  )


coef(penguins_lm)
coef(penguins_sddr)


library(ggplot2)
library(dplyr)

penguins %>%
  mutate(fitted_lm = fitted(penguins_lm), fitted_sddr = fitted(penguins_sddr)) %>%
  ggplot(aes(x = fitted_lm, y = fitted_sddr)) +
  geom_point()

penguins %>%
  mutate(fitted_lm = fitted(penguins_lm), fitted_sddr = fitted(penguins_sddr)) %>%
  ggplot(aes(x = bill_length_mm, y = fitted_sddr)) +
  geom_point()

penguins %>%
  mutate(fitted_lm = fitted(penguins_lm), fitted_sddr = fitted(penguins_sddr)) %>%
  ggplot(aes(x = bill_length_mm, y = fitted_lm)) +
  geom_point()
