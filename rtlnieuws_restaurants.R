
for(i in 1:1000)
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
