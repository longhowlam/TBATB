library(shinydashboard)
library(text2vec)
library(dplyr)
library(plotly)
library(stringr)

#################################  UI PART ###########################################################

ui <- dashboardPage(
  dashboardHeader(title = "The Bold and the Beautiful character lookup app", titleWidth = 600),
  dashboardSidebar(
    width=300,
    sidebarMenu(
      menuItem("Introduction", tabName = "introduction", icon = icon("dashboard")),
      menuItem("character distances", tabName = "WordEmbeddings", icon = icon("dashboard")),
      menuItem("character distances plot", tabName = "WordEmbeddings2", icon = icon("dashboard")),
     # menuItem("Word Embeddings Associated", tabName = "WordEmbeddings2", icon = icon("dashboard")),
      textInput("word", "character to search for", value="wyatt"),
      #textInput("word1", "Word association 1", value="man"),
      #textInput("word2", "Word association 2", value="vrouw"),
      numericInput("nw", "Number of similar words", value = 15)
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "introduction",
        h3("Introduction"),
        list(
          h4("Using the R text2vec package, I have used daily recaps of the Bold and the Beautiful of the last 15 years to generate word embeddings.
             With these word embeddings, distances between characters (and words in general) can be calulated. This can be handy if you 
             have never watched B&B, and you want to find out which charachters are related to each other"),
          p(" "),
          h4("Click on character distances on the left and type in a character to search for related characters.
             For recaps and R code see",  tags$a(href="https://github.com/longhowlam/TBATB", "my GitHub")),
          h4("Cheers, Longhow")
          ),
        mainPanel(
          htmlOutput("intro")
        )
      ),
      tabItem(
        tabName = "WordEmbeddings",
        h4("Bold and Beautiful character distances table"),
        fluidRow(
          dataTableOutput('we')
        )
      ),
      tabItem(
        tabName = "WordEmbeddings2",
        h4("Bold and Beautiful character distances plot"),
        fluidRow(
          plotOutput('we2')
        )
      )
    )
    )
  )


################################  SERVER PART ########################################################


word_vectors = readRDS("data/word_vectors_BB.RDs")
woorden = rownames(word_vectors)

server <- function(input, output, session) {
  
  ######## reactive function #################
  
  output$intro <- renderUI({
    list(
      img(src="BBchars.png")
    )
  })

  ######## TABLE with closest words #############################
  
  output$we = renderDataTable({
    charBB = str_to_lower(input$word)
    if(charBB %in% woorden)
    {
      WV <- word_vectors[str_to_lower(input$word), , drop = FALSE]
      cos_sim = sim2(x = word_vectors, y = WV, method = "cosine", norm = "l2")
      tmp = data.frame(
        head(
          sort(cos_sim[,1], decreasing = TRUE), 
          input$nw
        )
      )
      tmp2 = tibble(
        Words = row.names(tmp),
        similarity = tmp[,1]
      )
      tmp2 %>% dplyr::filter(similarity < 0.9999)
      
    }
  })
  
  output$we2 = renderPlot({
    charBB = str_to_lower(input$word)
    if(charBB %in% woorden)
    {
      WV <- word_vectors[str_to_lower(input$word), , drop = FALSE]
      cos_sim = sim2(x = word_vectors, y = WV, method = "cosine", norm = "l2")
      tmp = data.frame(
        head(
          sort(cos_sim[,1], decreasing = TRUE), 
          input$nw
        )
      )
      tmp2 = tibble(
        Words = row.names(tmp),
        similarity = tmp[,1]
      )
      titeltje = paste("mean centralized character distances for ", charBB)
      tmp2 = tmp2 %>% dplyr::filter(similarity < 0.9999)  
      
      m = mean(tmp2$similarity)
      tmp2$val = tmp2$similarity - m
      p = ggplot(tmp2, aes(x = Words)) +
        geom_bar(aes(weight=val), color="black") + 
        coord_flip() +
        labs(y="mean centralized character distance") +
        ggtitle(titeltje )
      p
    }
  })  
}

shinyApp(ui, server)