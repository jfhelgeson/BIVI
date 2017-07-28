#dropdown variables
vars <- c(
  "SVI Theme 1 Score" = "SVITheme1Score",
  "SVI Theme 2 Score" = "SVITheme2Score",
  "SVI Theme 3 Score" = "SVITheme3Score",
  "SVI Theme 4 Score" = "SVITheme4Score",
  "SVI Themes Score" = "SVIThemesScore",
  "SVI Overall Score" = "SVIOverallScore",
  "BIVI Theme 1 Score" = "BIVITheme1Score",
  "BIVI Theme 2 Score" = "BIVITheme2Score",
  "BIVI Theme 3 Score" = "BIVITheme3Score",
  "BIVI Theme 4 Score" = "BIVITheme4Score",
  "BIVI Themes Score" = "BIVIThemesScore",
  "BIVI Overall Score" = "BIVIOverallScore"
)

#separate variable groups for density plot
SVIvars <- c(
  "SVI Theme 1 Score" = "SVITheme1Score",
  "SVI Theme 2 Score" = "SVITheme2Score",
  "SVI Theme 3 Score" = "SVITheme3Score",
  "SVI Theme 4 Score" = "SVITheme4Score",
  "SVI Themes Score" = "SVIThemesScore",
  "SVI Overall Score" = "SVIOverallScore"
)

BIVIvars <- c(
  "BIVI Theme 1 Score" = "BIVITheme1Score",
  "BIVI Theme 2 Score" = "BIVITheme2Score",
  "BIVI Theme 3 Score" = "BIVITheme3Score",
  "BIVI Theme 4 Score" = "BIVITheme4Score",
  "BIVI Themes Score" = "BIVIThemesScore",
  "BIVI Overall Score" = "BIVIOverallScore"
)

#Creating top navbar
shinyUI(
  navbarPage("Vulnerability Indices App", id = "nav", 
             #creating first tab in navbar (map)                      
             tabPanel("Index Map",
                      tags$head(
                        # Include our custom CSS
                        includeCSS("flatly.css")
                      ),
                      div(class="outer",
                          
                          tags$head(
                            # Include our custom CSS
                            includeCSS("styles.css"),
                            includeScript("activemap.js")
                          ),
                          
                          leafletOutput("map", width="100%", height="100%"),
                          
                          # Shiny versions prior to 0.11 should use class="modal" instead.
                          absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                        draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                        width = 250, height = "auto",
                                        
                                        h2("Index Selector"),
                                        
                                        selectInput("color", "Color", vars, selected = "SVIOverallScore"),
                                        
                                        checkboxInput("hazrisk", "Multiply by Hazard Risk"),
                                        
                                        actionButton("reset_button", "Reset View")
                                        
                          )
                      )
                      
             ),
             
             #differences in the indices
             tabPanel("Differences in the Indices Spatially",
                      div(class="outer",
                          
                          tags$head(
                            # Include our custom CSS
                            includeCSS("styles.css"),
                            includeScript("activemap.js")
                          ),
                          
                          leafletOutput("diffmap", width="100%", height="100%"),
                          
                          # Shiny versions prior to 0.11 should use class="modal" instead.
                          absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                        draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                        width = 250, height = "auto",
                                        
                                        h4("Difference Between the BIVI and SoVI Scores"),
                                        
                                        actionButton("reset_button_diff", "Reset View"),
                                        
                                        checkboxInput("hazrisk_diff", "Multiply by Hazard Risk"),
                                        
                                        p("This map displays the differences in the overall index scores at the county
                                          level. The higher numbers represent the BIVI being higher, while the lower numbers
                                          represent the SoVI being higher."),
                                        p("Note: Please allow for a few seconds when checking the \"Multiply by Hazard Risk\"
                                          button due to time it takes to transform the data.")
                                        
                          )
                      )
                      
             ),
             
             
             ##data table tab             
             tabPanel("Data",
                      fluidRow(
                        #for selecting states (multiple choices possible)
                        column(3,
                               selectInput("states", "States", c("All states"="", structure(state.abb, names=state.abb), "Washington, DC"="DC"), multiple=TRUE)
                        ),
                        #For selecting unique county names if a state has been decided
                        column(3,
                               conditionalPanel("input.states",
                                                selectInput("counties", "Counties", c("All counties"="", structure(cnty, names = cnty)), multiple=TRUE)
                               )
                        )
                      ),
                      hr(),
                      #output the data table
                      DT::dataTableOutput("indextable")
             ),
             
             
             #new tab for density plot
             tabPanel("Density Plots",
                      fluidRow(
                        column(3,
                               selectInput("xaxis","X-Axis", BIVIvars, selected = "BIVIOverallScore"),
                               
                               br(),
                               
                               selectInput("yaxis", "Y-Axis", SVIvars, selected = "SVIOverallScore"),
                               
                               br(),
                               #checkbox on whether to include linear regressions
                               checkboxInput("line", "Linear Regression Line")
                        ),
                        column(9,
                               plotOutput("densityplot")
                        )
                        
                      ),
                      
                      fluidRow(
                        h4((textOutput("correlation")), style = "color:#1C2833"
                        ),
                        h4((textOutput("linreg")), style = "color:#1C2833"
                        )
                      )
                      
                      
                      
             ),
             
             tabPanel("App Information",
                      sidebarLayout(position = "right",
                                    sidebarPanel(
                                      h2("Features:", style = "color:#1C2833"),
                                      h4("Interactive Choropleth Map",style = "color:#2471A3"),
                                      p("The interactive choropleth map is under the \"Index Map\" in the navigation bar.
                                        Within the map, a map of the United States divided into counties can be filled based
                                        upon the index used, and the scale will change accordingly. A higher vulnerability
                                        is indicated by a higher score. Scores are cased upon quartiles, so, if the selection is in the upper
                                        quartile, it will receive a score of 3. The exception to this scoring system is the Overall score, which 
                                        is the sum of the 4 sub-components within it. The map can also be hovered over in order to reveal the location
                                        and the score associated with the area which is being hovered over. The checkbox labeled \"Multiply by Hazard Risk\"
                                        uses the hazard risk score generated by the Presidential Disaster Declarations data to scale the index score.
                                        Finally, the \"Reset View\" button
                                        can be used to return the map to its original viewing settings."),
                                      p("The map that displays the difference between the indices scores compares the overall scores 
                                        of the two indices and takes the difference. Higher values are associated with a higher BIVI, while
                                        lower scores are associated with a higher SoVI. The map is descriptive of the areas in which the indices
                                        do not pair well"),
                                      h4("Data Table", style = "color:#2471A3"),
                                      p("The data table can be found under the \"Data\" tab. This data table allows for a more specified 
                                        view of the data. The features within the table include the option to select one or more states, and, 
                                        after selecting a state, a county name can be looked up as well. In addition to the filtering, the data 
                                        can be sorted on any of the shown categories by clicking on the arrows next to the name."),
                                      h4("Interactive Plot", style = "color:#2471A3"),
                                      p("The interactive plot in this application is a density plot. The indices include discrete
                                        values, and, in order to view them effectively, a size is associated with the number of times 
                                        the value occurs. The density plot can be changed by what section of the BIVI is selected for
                                        the x-axis and the y-axis can be changed based on what section of the SoVI is selected. In addition
                                        to the plot itself, a linear regression line can also be plotted. If the indices were very similar in their
                                        scoring, a line would be produced which would represent a 1:1 ratio (assuming the scales are the same).")
                                    ),
                                    mainPanel(
                                      h2("The Vulnerability Indices", style = "color:#1C2833"),
                                      h4("Vulnerability", style = "color:#2471A3"),
                                      hr(style = "color:#2471A3"),
                                      p("Vulnerability serves as a relative measure of the propensity or predisposition
                                        of a community to be adversely affected by a shock or stress. Vulnerability can 
                                        be based upon many different types of factors. This application looks at two indices,
                                        one based upon social factors and the other based upon infrastructural factors."),
                                      h4("The Social Vulnerability Index (SoVI)", style = "color:#2471A3"),
                                      hr(style = "color:#2471A3"),
                                      p("The SVI is an index composed of social factors(Cutter et al. 2013). A widely used version and the version 
                                        used for this aapplication is from the Center for Disease Control and Prevention. The index 
                                        covers four different components/themes from quantifiable social factors and it updated every
                                        few years. The four components/themes represented by the SoVI are socioeconomic status, household
                                        composition, minority statuus/language, and housing/transportation. In order to create a comparison
                                        between indices, the scores were adjusted by using the same scoring system that was utilized in the 
                                        Built Infrastructure Vulnerability Index"),
                                      h5(strong(em("Theme 1: Socioeconomic Status"))),
                                      p("Socioeconomic status spans variables which are related to the economic wellbeing of
                                        people. Variables included are impoverished persons, unemployment, per capita income, and
                                        persons over the age of 25 without a highschool diploma"),
                                      h5(strong(em("Theme 2: Household Composition"))),
                                      p("Household Composition consists of three variables which are associated with a more vulnerable
                                        household. the variables included are persons age 65 or older, persons age 17 or younger, and single
                                        parent households with children under 18"),
                                      h5(strong(em("Theme 3: Minority Status/Language"))),
                                      p("Minority status/language consists of variables associated with the density and communicative abilities
                                        of minority populations. The variables contained within this theme are persons who are classified as a minority
                                        group, persons who are over the age of 5 who speak english \"less than well\"."),
                                      h5(strong(em("Theme 4: Housing/Transportation"))),
                                      p("Housing/transportation consists of variables which are related to the types of housing,
                                        status of housing, and availibility of transportation. Variables included within this theme include 
                                        housing structures with 10+ units, mobile homes, occurance of more people than rooms at the household level, 
                                        persons in institutionalized group headquarters, and the availibility of personal transportation"),
                                      h4("The Built Infrastructure Vulnerability Index (BIVI)", style = "color:#2471A3"),
                                      hr(style = "color:#2471A3"),
                                      p("The BIVI is a vulnerability index based upon built inftastructure. Its purpose is to provide another means
                                        for determining an areas vulnerability. It is meant as to be complimentary to the SVI as one type of indicator 
                                        is not representative of the whole. This change in scores between the areas based on the indices displays just
                                        how much the scores can differ based upon what indicator is being observed. The BIVI covers four themes as well:
                                        housing, resupply potential, establishment access, and connectivity"),
                                      h5(strong(em("Theme 1: Housing"))),
                                      p("Housing within the BIVI contains only variables associated with construction dates. In research, the construction year
                                        was found to have a connection to many underlying variables (Checkoway, 1980; Harris, 2005). The cutoff year for construction 
                                        of the house determined to be the most significant and used in this index is 1960"),
                                      h5(strong(em("Theme 2: Resupply Potential"))),
                                      p("Resupply Potential deals with variables associated with railroads. The importance of the railroad variables is that railroads are
                                        a common way to transport a mass amount of people, and also a way to transport a mass amount or resources. So, If people can be moved
                                        out and resources can be brought in mass quantities, it provides the community the tools to prepare and recover from a hazard"),
                                      h5(strong(em("Theme 3: Establishment Access"))),
                                      p("Access to certain establishments or the availibility of many establishments can be essential to a community. Certain establishments 
                                        such as hospitals and schools can assist in mitigating the effects of a hazard because hospitals can provide care and schools can 
                                        provide shelter. Also, the more establishments that are availible can lead to an availibility of establishments after access which 
                                        will allow the economy to stay active after the events of a hazard."),
                                      h5(strong(em("Theme 4: Connectivity"))),
                                      p("Connectivity deals with the ability to communicate effectively and quickly to a population. Broadband has become very comon now,
                                        so the people who do not currently have it cannot communicate as easily or be communicated to as easily.  As a result, the areas
                                        without broadband connection will not be as easily notified of a hazard such as a tornado and will not be able to communicate to outside 
                                        resources about a hazard affecting them."),
                                      h4("Presidential Disaster Declarations (hazard risk)", style = "color:#2471A3"),
                                      hr(style = "color:#2471A3"),
                                      p("Presidential Disaster Declarations have been around since 1953. Disasters are declared when the president determines that
                                        there is a need for federal assistance and/or the extent of damage excedes the capabilities of the state. The declarations cover a wide 
                                        variety of disasters such as terrorist attacks, chemical spills, tornados, hurricanes, etc. In this application, the scaling of the other data
                                        is done by assigning values to the occurance count of disaster declaraions at the county level and using that score as a multiplier. The integer
                                        scale is from 1-4, where, if a county is in the upper quartile (top 25%) in terms of disaster declarations, the county would receive a score of 4")
                                    )
                      )
             ),
             
             tabPanel("More Information",
                      sidebarLayout(position = "right",
                                    sidebarPanel(
                                      h3("References:", style = "color:#2471A3"),
                                      p("Cutter et al. 2003. “Social Vulnerability to Environmental Hazards,” Social Science Quarterly 84 (1): 242-261."),
                                      p("Fourie, J. 2006. “ECONOMIC INFRASTRUCTURE: A REVIEW OF DEFINITIONS, THEORY AND EMPIRICS,” South African Journal of Economics: Vol. 74: Iss. 3."),
                                      p("Yeomans, K. and Golder, P. 1982. “The Guttman-Kaiser Criterion as a Predictor of the Number of Common Factors,” Journal of the Royal Statistical Society. Series D (The Statistician), Vol. 31: Iss. 3."),
                                      p("DiStefano, C.; Zhu, M.; and Mindrila, D. 2009. \"Understanding and Using Factor Scores: Considerations for the Applied Researcher,\" Practical Assessment, Research & Evaluation, Vol.14 : Iss. 20"),
                                      h3("Data Gathered From:"),
                                      p("Center for Disease Control and Prevention, US Census Bureau, Federal Communications Commision, Bureau of Transportation","Federal Emergency Management Association"),
                                      br(),
                                      h5("Acknowledgements", style = "color:#2471A3"),
                                      p("Bootswatch, Mapbox, OpenStreetMap, ESRI"),
                                      hr(),
                                      br(),
                                      img(src="nist_logo.png", height = 50, width = 300)
                                    ),
                                    mainPanel(
                                      h3("Developer Information", style = "color:#2471A3"),
                                      hr(style = "color:#2471A3"),
                                      p("Applied Economics Office"),
                                      p("Engineering Laboratory"),
                                      p("National Institute of Standards and Technology"),
                                      p("100 Bureau Drive, Mail Stop 8603"),
                                      p("Gaithersburg, MD 20899-8603"),
                                      br(),
                                      h3("Contact Information", style = "color:#2471A3"),
                                      hr(style = "color:#2471A3"),
                                      p("Jennifer F. Helgeson, PhD:"),
                                      p("Email: jennifer.helgeson@nist.gov"),
                                      p("Tel.: (301) 975-6133"),
                                      br(),
                                      p("Elias Nicholson:"),
                                      p("Email: efn3@hood.edu"),
                                      br(),
                                      p("Thank you to all those who contributed ideas and suggestions for this research: David Butry, NIST; Stephen Cauffman, NIST; Maria Dillard, NIST; Juan Fung, NIST; Ken Harrison, NIST; Erica Kuligowski, NIST"),
                                      br(),
                                      h3("More information about Community Resilience Planning at NIST", style = "color:#2471A3"),
                                      hr(style = "color:#2471A3"),
                                      p("NIST Community Resilience:",
                                      a("https://www.nist.gov/topics/community-resilience", href = "https://www.nist.gov/topics/community-resilience")),
                                      p(em("Community Resilience Economic Decision Guide for Buildings and Infrastructure Systems (EDG):"),
                                      a("http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.1197.pdf", href = "https://www.nist.gov/topics/community-resilience")),
                                      p(em("Community Resilience Economic Guide Brochure: "),
                                      a("https://www.nist.gov/sites/default/files/documents/2017/01/23/nist_communityresilience_brochure-11b_finaldec2016.pdf", href = "https://www.nist.gov/topics/community-resilience"))
                                      
                                      )
                                    )
                      ),
             
                       conditionalPanel("false", icon("crosshair"))
  )
)

