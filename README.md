### Introduction
This shiny application performs sentiment analysis [algorithm](https://jeffreybreen.wordpress.com/2011/07/04/twitter-text-mining-r-slides/)  of the tweets of the two words. It first establishes connection with [Twitter](https://twitter.com/) using OAuth. Then, based on the inputs (please see below), recent tweets of each word are retrieved and matched with a list of terms deemed [positive or negative](https://github.com/jeffreybreen/twitter-sentiment-analysis-tutorial-201107/tree/master/data/opinion-lexicon-English). A sentiment score is subsequently generated for each tweet. Finally, the distribution of sentiment scores is presented using box plots with the means computed. Note that the application can take a while to load.

### Inputs (side panel)
1. Textboxes to enter the two words for analysis
2. Slider to select the number of recent tweets for each word to analyse

### Outputs (tab panel)
* **1st Tab**: Documentation to get started using the application
* **2nd Tab**: (Reactive Output) Sentiment scores and cleaned tweets of word 1
* **3rd Tab**: (Reactive Output) Sentiment scores and cleaned tweets of word 2
* **4th Tab**: Word clouds of terms used in tweets for both words
* **5th Tab**: (Reactive Output) Box plots of the distribution of sentiment scores

### Endnote
Hope you will enjoy using the application which is completed in a relatively short time frame.

### Run Code Offline
The [code](https://github.com/kwektuanze/Developing_Data_Products_Course_Project) (including server.R and ui.R) is shared on github. To run on local machine, git clone the code to working directory, set up Twitter connection by replacing <code>setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
</code>(in server.R) with your Twitter OAuth credentials. Then load <code>shiny</code> library and run <code>runApp("Developing_Data_Products_Course_Project")</code> command.
