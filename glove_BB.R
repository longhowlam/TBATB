############################################################################################################

### Glove on Bold and Beautifull recaps

library(stringr)
library(text2vec)
library(visNetwork)
library(ggplot2)
library(plotly)
library(stopwords)

#### import recpas of BB ################################################################
AllBB = readRDS("data/AllBB.RDs")


#### transform to lower and create tokens

AllBB$recapsclean =  str_replace_all(AllBB$recaps, "\n", "") %>% tolower
AllBB$id = 1:dim(AllBB)[1]
stopw = c(stopwords::stopwords(), letters)

####### tokenize, iterate and create vocab  ###################################
it_train =  AllBB$recapsclean %>%
  word_tokenizer() %>% 
  itoken(
    ids = AllBB$id,
    progressbar = TRUE
  )

pruned_vocab = it_train %>% 
  create_vocabulary(
    ngram = c(ngram_min = 1L, ngram_max = 1L),
    stopwords = stopw
  ) %>% 
  prune_vocabulary(
    term_count_min = 5 ,
    doc_proportion_max = 0.95
  )

vectorizer <- vocab_vectorizer(
  pruned_vocab
)

#### Create the so-called term co-occurence matrix ############################
tcm <- create_tcm(
  it_train, 
  vectorizer, 
  skip_grams_window = 5L
)


## first two words in the tcm matrix are "miraculously" and fearfully
tcm[1:2,1:2]

## words that occur often in the neighborhood of 'miraculously' 
x =  tcm[1,] 
x [x > 0]


#######  Glove word embeddings

## This can take some time, about an hour on my little 4 core server.
t0 = proc.time()

glove = GlobalVectors$new(
  word_vectors_size = 250, 
  vocabulary = pruned_vocab,
  x_max = 10, 
  learning_rate = 0.07
)

word_vectors = glove$fit_transform(tcm, n_iter = 30)
dim (word_vectors)


t1 = proc.time()
t1-t0

## save the wordvectors

saveRDS(word_vectors, "data/word_vectors_BB.RDs")

word_vectors = readRDS("data/word_vectors_BB.RDs")

###### distances between some characters ################################################

BBchars = c("quinn", "eric", "steffy", "ridge", "bill", "brooke", "caroline", "liam",   "thomas", "taylor", "rick", "bridget")

ff = function(word)
{
  WV <- word_vectors[word, , drop = FALSE] 
  cos_sim = sim2(x = word_vectors, y = WV, method = "cosine", norm = "l2")
  tmp = head(sort(cos_sim[,1], decreasing = TRUE), 8)
  tibble::tibble(from = word, to = names(tmp), value = tmp)
}

BBcharsDistances = purrr::map_dfr(BBchars, ff)

## subtract mean just for plotting purposes....
## remove distance "one"

BBcharsDistances$value2 = BBcharsDistances$value - mean( BBcharsDistances$value)
BBcharsDistances = BBcharsDistances  %>% dplyr::filter(value < 0.99)


#### create plot with character distances ###############################################

p = ggplot(
  BBcharsDistances, aes(x = to)
) +
  geom_bar(
    aes(weight=value2), color="black"
  ) + 
  facet_wrap( ~from ) +
  coord_flip() +
  labs( y = "person similarity") +
  ggtitle("Word-embedding distances between Bold & Beautiful characters")

p


ff("steffy")

### word minus other word linguistic regularities

twowords = function(w1,w2){
  out = word_vectors[w1, , drop = FALSE] - 
    word_vectors[w2, , drop = FALSE]

  cos_sim = sim2(x = word_vectors, y = out, method = "cosine", norm = "l2")
  head(sort(cos_sim[,1], decreasing = TRUE), 7)
}

twowords("steffy", "liam")

