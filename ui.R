shinyUI(fluidPage(
  headerPanel("Twitter - Sentiment Analysis"),
  
  #Inputs
  sidebarPanel(
    wellPanel(
      #Input word 1 and word 2 for analysis
      textInput("word1", "Word 1: ", "#iphone6"),
      textInput("word2","Word 2: ", "#s6"),
            HTML("<div style='font-size: 10px;font-weight: bold'> Replace the above words with your own (can take '@' or hashtag with '#').</div>")
    ),
    wellPanel(
      #Input number of recent tweets for each word to analyse
      sliderInput("maxTweets", "Number of recent tweets to analyse: ", min=10, max=300, value=50, step=10)
    )
  ),
  #Outputs
  mainPanel( 
    tabsetPanel(
      #Output of documentation to get started using the application
      tabPanel("Documentation", includeMarkdown("README.md")),      
      #Output of sentiment scores and cleaned tweets
      tabPanel("Scores/Tweets of Word 1", tableOutput("word1output")),
      tabPanel("Scores/Tweets of Word 2", tableOutput("word2output")),
      #Output of word clouds of terms used in tweets for both words
      tabPanel("Word Clouds", h2(textOutput("word1wc")), plotOutput("word1wcplot"), h2(textOutput("word2wc")), plotOutput("word2wcplot")),
      #Output showing box plots of the distribution of sentiment scores
      tabPanel("Sentiment Analysis", plotOutput("sentimentboxplot"),
               HTML("<div>The above shows distribution of sentiment scores about each word. For each tweet, a net score of positive (greater than 0) / negative (smaller than 0) / neutral (equal to 0) sentiments is calculated. Blue dots are mean sentiment scores for the two words.</div>"))
    )
  )
))