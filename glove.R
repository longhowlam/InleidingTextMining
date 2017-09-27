library(feather)
library(text2vec)
library(dplyr)
library(anytime)
library(ggplot2)
library(stringr)

####  import scraped news articles from RTL

### data set moet nog van mijn gdrive gehaald worden onder DutchWordEmbeddings
RTLN = readRDS("data/RTLNIEUWS01.RDs")



## voor nu even nos artieklen
RTLN = readRDS("data/AllNieuws.RDs")
RTLN$id = 1:dim(RTLN)[1]

### overview of articles per day
hist(RTLN$date, breaks = "month")

### text mine, tokenize etc.
RTLNEWS_tokens = RTLN$bodie %>%
  word_tokenizer

##### and use the tokens to create an iterator and vocabular
it_train = itoken(
  RTLNEWS_tokens, 
  ids = RTLN$nid,
  progressbar = TRUE
)


stopwoorden = readRDS("data/stopwoorden.RDs")

vocab = create_vocabulary(
  it_train, 
  ngram = c(ngram_min = 1L, ngram_max = 1L),
  stopwords = stopwoorden
)
vocab

pruned_vocab = prune_vocabulary(
  vocab, 
  term_count_min = 25 ,
  doc_proportion_max = 0.85
)

print("*** vocab generated****")
print(pruned_vocab)

vectorizer <- vocab_vectorizer(
  pruned_vocab, 
  # don't vectorize input
  grow_dtm = FALSE, 
  # use window of 5 for context words
  skip_grams_window = 5L
)

tcm <- create_tcm(it_train, vectorizer)
dim(tcm)

#######  Glove word embeddings

glove = GlobalVectors$new(word_vectors_size = 250, vocabulary = pruned_vocab, x_max = 10)
glove$fit(tcm, n_iter = 30)
word_vectors = glove$get_word_vectors()

dim(word_vectors)
word_vectors[1,]


###### distances between words....
WV <- word_vectors["aanslag", , drop = FALSE] 
cos_sim = sim2(x = word_vectors, y = WV, method = "cosine", norm = "l2")
head(sort(cos_sim[,1], decreasing = TRUE), 20)




