library(ggplot2)
library(plyr)
library(shiny)
library(stringr)
library(tm)
library(twitteR)
library(wordcloud)
library(markdown)

#Twitter OAuth with token cache
origop<-options("httr_oauth_cache")
options(httr_oauth_cache=TRUE)
setup_twitter_oauth("jhDUfOPgDrov0Vcn5IodKa0iN", "FXjD6OWwUEjJtNxuCXhkPglKCAYHdUO2i3kogs8PZBxoBnW3gB", "3163543724-Rs8hQpHN79iK5qCVfFADFAJyNqUhvOsye6KkrxX", "BvF2Cb6JikThKxEAG70HjPEYKQBDlk4CWA8eieb37QuAz")
options(httr_oauth_cache=origop)

shinyServer(function(input, output) {
  
  #Tweets search and return resultant data frame
  searchTweets<-function(searchWord, maxTweets) {
    searchResult<-searchTwitter(searchWord, n=maxTweets, lang="en")
    searchResultDf<-do.call("rbind", lapply(searchResult, as.data.frame))
    searchResultDf$text<-iconv(searchResultDf$text, 'UTF-8', 'ASCII')
    return(searchResultDf)
  }
  
  #Data preparation on tweets
  cleanTweets<-function(tweets) {
    #Remove spaces
    tweets<-str_replace_all(tweets, " ", " ")
    #Remove URLs
    tweets<-str_replace_all(tweets, "http://t.co/[a-z,A-Z,0-9]*{8}", "")
    #Remove retweet header
    tweets<-str_replace(tweets, "RT @[a-z,A-Z]*: ", "")
    #Remove hashtags
    tweets<-str_replace_all(tweets, "#[a-z,A-Z]*", "")
    #Remove screen name references
    tweets<-str_replace_all(tweets, "@[a-z,A-Z]*", "")
    return(tweets)
  }
  
  #Word cloud generation
  generateWordCloud<-function(tweets) {
    tweetCorpus<-Corpus(VectorSource(cleanTweets(tweets)))
    tweetTdm<-TermDocumentMatrix(tweetCorpus, control=list(stopwords=c(stopwords("english")), removePunctuation=TRUE, removeNumbers=TRUE, tolower=TRUE))
    #Create matrix for data manipulation
    tweetMatrix<-as.matrix(tweetTdm)
    #Calculate row sum of each tweet term and sort in descending order (high to low freq)
    sortedMatrix<-sort(rowSums(tweetMatrix), decreasing=TRUE)
    #Extract related words from matrix to form word cloud
    cloudFrame<-data.frame(word=names(sortedMatrix), freq=sortedMatrix)
    print(wordcloud(cloudFrame$word, cloudFrame$freq, max.words=100, scale=c(4,0.5), colors=brewer.pal(8, "Dark2"), random.order=TRUE))
  }
  
  #Scoring sentiment based on Jeffrey Breen's algorithm: https://jeffreybreen.wordpress.com/2011/07/04/twitter-text-mining-r-slides
  score.sentiment = function(sentences, pos.words, neg.words) {
    
    scores = laply(sentences, function(sentence, pos.words, neg.words) {
      # clean up sentences with R's regex-driven global substitute, gsub():
      sentence = gsub('[[:punct:]]', '', sentence)
      sentence = gsub('[[:cntrl:]]', '', sentence)
      sentence = gsub('\\d+', '', sentence)
      # and convert to lower case:
      sentence = tolower(sentence)
      
      # split into words. str_split is in the stringr package
      word.list = str_split(sentence, '\\s+')
      # sometimes a list() is one level of hierarchy too much
      words = unlist(word.list)
      
      # compare our words to the dictionaries of positive & negative terms
      pos.matches = match(words, pos.words)
      neg.matches = match(words, neg.words)
      
      # match() returns the position of the matched term or NA
      # we just want a TRUE/FALSE:
      pos.matches = !is.na(pos.matches)
      neg.matches = !is.na(neg.matches)
      
      # and conveniently enough, TRUE/FALSE will be treated as 1/0 by sum():
      score = sum(pos.matches) - sum(neg.matches)
      
      return(score)
    }, pos.words, neg.words)
    
    scores.df = data.frame(score=scores, cleaned_tweets=sentences)
    return(scores.df)
  }
  
  #Sentiment analysis
  sentimentAnalysis<-function(word1tweets, word2tweets, word1, word2) {
    
    #List of positive and negative words from Jeffrey Breen's GitHub: https://github.com/jeffreybreen/twitter-sentiment-analysis-tutorial-201107/tree/master/data/opinion-lexicon-English
    positivewords=readLines("positive_words.txt")
    negativewords=readLines("negative_words.txt")
    
    #Apply score.sentiment algorithm
    word1score=score.sentiment(cleanTweets(word1tweets), positivewords, negativewords)
    word2score=score.sentiment(cleanTweets(word2tweets), positivewords, negativewords)
    
    #Add labels [word1] and [word2] for ggplot of the analysis
    word1score$word=word1
    word2score$word=word2
    
    #Combine scores
    sentimentScores<-rbind(word1score, word2score)
  }   
  
  #Read word 1 and word 2, and search the related tweets (using reactive expressions)
  searchResult1<-reactive({searchResult1<-searchTweets(input$word1, input$maxTweets)})
  searchResult2<-reactive({searchResult2<-searchTweets(input$word2, input$maxTweets)})
  
  #Create sentiment scores
  sentimentScores<-reactive({sentimentScores<-sentimentAnalysis(searchResult1()$text, searchResult2()$text, input$word1, input$word2)})
  
  #Output Tab 1 - Scores/Tweets of Word 1
  output$word1output<-renderTable({tab<-head(sentimentScores(), input$maxTweets)})
  
  #Output Tab 2 - Scores/Tweets of Word 2
  output$word2output<-renderTable({tab<-tail(sentimentScores(), input$maxTweets)})  
  
  #Output Tab 3 - Word Clouds
  output$word1wc<-renderText({input$word1})
  output$word1wcplot<-renderPlot({generateWordCloud(searchResult1()$text)})
  
  output$word2wc<-renderText({input$word2})
  output$word2wcplot<-renderPlot({generateWordCloud(searchResult2()$text)})
  
  #Output Tab 4 - Box plots of the distribution of sentiment scores
  output$sentimentboxplot<-renderPlot({sentimentboxplot<-ggplot(sentimentScores(), aes(x=word,y=score,fill=word))+
                                         geom_boxplot()+
                                         geom_jitter(alpha=.3)+
                                         theme(axis.text.x = element_text(color="black"))+
                                         theme(axis.text.y = element_text(color="black"))+
                                         theme(legend.position="none")+labs(x="")+
                                         stat_summary(fun.y=mean, geom="point",color="blue", size=5)
                                       print(sentimentboxplot)})  
})