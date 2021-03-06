% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/html_to_pdf.R
\name{html_to_pdf}
\alias{html_to_pdf}
\title{Convert HTML to PDF}
\usage{
html_to_pdf(file_path = NULL, dir = NULL, scale = 1, render_exist = FALSE)
}
\arguments{
\item{file_path}{file path to the HTML file (can be relative if you are in a R project)}

\item{dir}{file path to the directory of all HTML files (can be relative if you are in a R project)}

\item{scale}{the scale of the PDF}

\item{render_exist}{overwrite exist PDF. Default is \code{FALSE}}
}
\value{
no return value
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}} \cr
This is a helper function for knitting Rmd. Due to technological limitation, the output cannot knit to PDF in Rmd directly. It uses the pagedown::chrome_print() in the backend.
You must first knit to HTML, then you can use this function to covert them to PDF if you wish. I know this is a workaround to the issue,
but the problem is with the latex engine printing unicode character. If you happen to know how to fix it, please let me know.
}
\examples{
\dontrun{
html_to_pdf(file_path = "html_name.html")
# all HTML files in the my_html_folder will be converted
html_to_pdf(dir = "Users/Desktop/my_html_folder")
}
}
