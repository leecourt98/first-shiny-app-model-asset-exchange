#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(httr)
library(dplyr)

# define the function for the app
generate_yelp_text <- function(insert_seed_text){
  
  # identify the model we want -- here it's the yelp text generator
  model_endpoint <- paste0('http://max-review-text-generator.max.us-south.containers.appdomain.cloud/',
                           'model/predict') 
  
  # assign data from function argument 
  data = paste('{\"seed_text\": \"', 
               insert_seed_text, 
               '\"}') # be sure to use single quotes up in here.
  
  # use POST to get the callback
  response <- httr::POST(url = model_endpoint,
                         httr::add_headers(.headers=c(`Content-Type` = 'application/json')),
                         body = data) %>% content()
  
  # return the following dataframe
  responses_df = do.call(what = rbind.data.frame, args = response$prediction)
  return(responses_df[3,1])
  
} # end function::generate_yelp_text


# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Generate some text similar to a yelp review!"),
   
   # Sidebar
   # sidebarLayout(position = "right",
   #               sidebarPanel(h3("sidebar filler text for now"),
   #                            br(),
   #                            br(),
   #                            br(),
   #                            p("<-- see left.")
   #                            ), # end sidebar content
    mainPanel(
      # h3("insert your own text here"),
      br(),
      p("Try your hand at generating some text similar to a Yelp Review!
        (according to some algorithms!)"),
      br(),
      br(),
      p("Constructed at R-Ladies SF by @leecourt98, 2019-05-18.")
    ),  # end main panel
  
   # start fluidrow
      fluidRow( 

        ), # end fluid row
   
      
      # Show all of our inputs and outputs
      mainPanel(
        
        textInput("text", h3("Your text input"), 
                  value = "Enter text..."), 
        
        actionButton("go", "Generate the Yelp text!"),
        
        
        h4("Your seed text is: "), 
        textOutput("string_var"),
        br(),
        h4("...and here's our algorithmically generated output:"),
        br(),
        textOutput("generated_yelp_text")
      ) #end main panel
   

   ) # end fluid page

# Define server logic required to produce the machine generated yelp text
server <- function(input, output) {
  
  generated_text <- eventReactive(input$go, {
    withProgress({
      setProgress(message = "Processing seed text...")
      generate_yelp_text(input$text)
    }) # end withProgress
  }) # end generated_text block
  
  output$string_var <- renderText({
    paste(input$text)
  }) # end  output$string_var

  output$generated_yelp_text <- renderText({
    paste(
        generated_text()
    ) #end paste
  }) # end render text
  
} # end server function

# Run the application 
shinyApp(ui = ui, server = server)

