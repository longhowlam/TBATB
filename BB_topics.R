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
    ngram = c(ngram_min = 1L, ngram_max = 2L),
    stopwords = stopw
  ) %>% 
  prune_vocabulary(
    term_count_min = 5 ,
    doc_proportion_max = 0.95
  )

wordcloud2(pruned_vocab, shape = "star", minSize = 2)

############### TOPIC MODELLING ####################################################


####### Topic modeling ###################################################################

# Topic modeling is een techniek (Latent Dirichlet Allocation) om een verzameling teksten te
# clusteren in een aantal topics Elk topic laat zich kenmerken door een aantal belangrijke woorden.

# Om topic modeling te doen, moet er eerst een zogenaamde document term matrix gemaakt
# worden. Dit gebeurt via de eerder gemaakte vocabulaire.

it_train = AllBB$recapsclean %>%
  word_tokenizer() %>% 
  itoken(
    ids = AllBB$id,
    progressbar = TRUE
  )

vectorizer = it_train %>% 
  create_vocabulary(
    ngram = c(ngram_min = 1L, ngram_max = 1L),
    stopwords = c(stopw, "said", "says", "told")
  ) %>% 
  prune_vocabulary(
    term_count_min = 5 ,
    doc_proportion_max = 0.95
  ) %>% 
  vocab_vectorizer()

## with a iterator and a vectorizer we can create a DTM
dtm = create_dtm(it_train, vectorizer)

dim(dtm)

# Een rij uit de matrix is een tekst met woord tellingen
dtm[1,1:15]

### Create and train a topic model with 10 topics
lda_model = LDA$new(
  n_topics = 10, 
  doc_topic_prior = 0.1, 
  topic_word_prior = 0.01
)

doc_topic_distr = lda_model$fit_transform(
  x = dtm, 
  n_iter = 1000, 
  convergence_tol = 0.0001, 
  n_check_convergence = 25, 
  progressbar = FALSE
)


#### Tabel topics ##################

## results of topics in the a tabel, take the 15 most important words per topc

onderwerpen = as.data.frame(
  lda_model$get_top_words(
    n = 15, lambda = 1
  )
)
names(onderwerpen) = paste0("TOPIC_", 1:10)
DT::datatable(onderwerpen,  options=list(pageLength = 15))

## we kunnen ook nu elke bezwaar voorzien van een topic nummer
## zo zien we hoeveel documenten / bezwaren er per topic zijn

AllBB$topic = apply(doc_topic_distr, 1, which.max)
AllBB %>% group_by(topic) %>% summarise(n=n())


####### visualisatie topics ##################
## the 10 topics can be projected in a 2 dimensional space
## this will give you an idea on how close certain topics are 
## volgende maakt een interactieve topic plot

lda_model$plot(out.dir = getwd())

#### original recaps with topc words ##############

## manier om nog meer inzicht te krijgen in de topics is om per topic wat 
## van de originele bewaren er bij te halen en die te lezen met 'verlichte' topicwoorden

## Neem bijvoorbeeld 20 willekeurige bezwaren van topic 3
## print ze en licht de woorden van topic 3 op


#### helper function to highlight words in a text
highlightwords = function (intexts, words)
{
  markwords = function(intext, words)
  {
    for(word in words)
    {
      wordrep = paste(
        "<mark>",
        word,
        "</mark>"
      )
      intext =   stringr::str_replace_all(intext, word, wordrep)
    }
    intext
  }
  
  outtexts = purrr::map_chr(intexts, markwords, words)
  DT::datatable(
    data.frame(text = outtexts),
    escape = FALSE,
    options=list(pageLength = 15)
  )
}


SOME_RECAPS = AllBB %>% filter(topic == 3) %>% sample_n(20)
highlightwords(
  SOME_RECAPS$recaps,
  onderwerpen$TOPIC_3
)



