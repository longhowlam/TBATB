library(stopwords)
library(wordcloud2)
library(dplyr)
library(text2vec)

pruned_vocab = 
  AllBB$recapsclean %>%
  word_tokenizer() %>% 
  itoken(
    ids = AllBB$id,
    progressbar = TRUE
  ) %>% 
  create_vocabulary(
    ngram = c(ngram_min = 1L, ngram_max = 1L),
    stopwords = stopw
  ) %>% 
  prune_vocabulary(
    term_count_min = 5 ,
    doc_proportion_max = 0.95
  )

wordcloud2(pruned_vocab, shape = "star", minSize = 2)

