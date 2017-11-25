library(pdftools)
library(purrr)
library(text2vec)
library(stringr)
library(wordcloud)
library(stopwords)

#install.packages("stopwords")
stopwords::stopwords$nl


######  download pdf's from RTL Nieuws
## They are just numberd i.pdf, but with some 'skips'

for(i in 1:300)
{
  tryCatch({
    f = paste0(
      "https://www.rtlnieuws.nl/sites/default/files/redactie/public/research/wobjournaals/doc",
      i,
      ".pdf"
    )

    out = paste0(i,".pdf")
    download.file(f,out,mode="wb")
    print(i)
  }, 
  error=function(e) {
    print("***")
    print(i)
  }
  )
}

###### import pdfs to do text mining on

pdfstexts = paste0(
  "RestaurantsBlacklist/", 
  list.files("RestaurantsBlacklist/")
  ) %>%
  map(pdf_text) %>%
  map(paste, collapse = " ") %>%
  unlist() %>%
  str_to_lower

### perform text mining

Rest_tokens = pdfstexts %>%
  word_tokenizer

##### and use the tokens to create an iterator and vocabular
it_train = itoken(
  Rest_tokens, 
  ids = 1:128,
  progressbar = TRUE
)

stopwoorden = c(
  stopwords::stopwords$nl,
  "2016", "verslag", "datum","code", "inspectie", "keuken", "bedrijf", "inspecteurs","gesprek","journaal",
  "nvt",
  letters,
  
  1:31)

  

vocab = create_vocabulary(
  it_train, 
  ngram = c(ngram_min = 1L, ngram_max = 2L),
  stopwords = stopwoorden
)

tmp = vocab$vocab


pruned_vocab = prune_vocabulary(
  vocab, 
  term_count_min = 10 ,
  doc_proportion_max = 0.7
  #,doc_proportion_min = 0.001
)


tmp = pruned_vocab$vocab

print("*** vocab generated****")
print(pruned_vocab)

vectorizer = vocab_vectorizer(pruned_vocab)
dtm_train = create_dtm(it_train, vectorizer)
















  
  
  