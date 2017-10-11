################################################

### Glove on Bold and Beautifull recaps
### LH

library(stringr)
library(text2vec)
library(visNetwork)
library(ggplot2)
library(plotly)

AllBB = readRDS("data/AllBB.RDs")

AllBB$recapsclean =  str_replace_all(AllBB$recaps, "\n", "") %>% tolower
AllBB$id = 1:dim(AllBB)[1]

AllBB_tokens = AllBB$recapsclean %>%
  word_tokenizer

##### and use the tokens to create an iterator and vocabular
it_train = itoken(
  AllBB_tokens, 
  ids = AllBB$id,
  progressbar = TRUE
)


stopw = c(tm::stopwords(), letters)

vocab = create_vocabulary(
  it_train, 
  ngram = c(ngram_min = 1L, ngram_max = 1L),
  stopwords = stopw
)
vocab

pruned_vocab = prune_vocabulary(
  vocab, 
  term_count_min = 5 ,
  doc_proportion_max = 0.95
)

print("*** vocab generated****")
print(pruned_vocab)

vectorizer <- vocab_vectorizer(
  pruned_vocab
)

tcm <- create_tcm(it_train, vectorizer, skip_grams_window = 5L)
dim(tcm)


#######  Glove word embeddings

## Dit duurt op mijn 4 cores servertje ruim een uur.
t0 = proc.time()

glove = GlobalVectors$new(word_vectors_size = 250, vocabulary = pruned_vocab, x_max = 10, learning_rate = 0.07)
word_vectors = glove$fit_transform(tcm, n_iter = 30)

t1 = proc.time()
t1-t0

## bewaar de wordvectors

saveRDS(word_vectors, "data/word_vectors_BB.RDs")
dim(word_vectors)


###### distances between some characters.

BBchars = c("quinn", "eric", "steffy", "ridge", "bill", "brooke", "caroline", "liam",   "thomas", "taylor", "rick", "bridget")


ff = function(word)
{
  WV <- word_vectors[word, , drop = FALSE] 
  cos_sim = sim2(x = word_vectors, y = WV, method = "cosine", norm = "l2")
  tmp = head(sort(cos_sim[,1], decreasing = TRUE), 10)
  tibble::tibble(from = word, to = names(tmp), value = tmp)
}

BBcharsDistances = purrr::map_dfr(BBchars, ff)

## subtract mean just for plotting purposes....
## remove distance "one"

BBcharsDistances$value2 = BBcharsDistances$value - mean( BBcharsDistances$value)
BBcharsDistances = BBcharsDistances  %>% dplyr::filter(value < 0.99)


p = ggplot(BBcharsDistances, aes(x = to)) +
  geom_bar(aes(weight=value2), color="black") + 
  facet_wrap(~from) +
  coord_flip() +
  labs(y="person similarity") +
  ggtitle("Word-embedding distances between Bold & Beautiful characters")

p

