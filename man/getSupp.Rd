\name{getSupp}
\alias{getSupp}

\title{ Get supplmentary tables }
\description{  Get supplementary tables from PMC  }
\usage{
getSupp(pmcid, file, type, opts = "-raw -nopgbrk", rm = TRUE, header = TRUE, pmc=TRUE, ...)
}

\arguments{
  \item{pmcid}{ id or  XML document with PMC id attribute }
  \item{file}{ supplementary file name  }
  \item{type}{ type of file, default to file extension }
  \item{opts}{ pdftotext options }
  \item{rm}{ remove downloaded files}
  \item{header}{ column labels in Word doc }
  \item{pmc}{  download from NCBI pmc  }
  \item{\dots}{ other options passed to \code{read} commands }
}
\details{ This function is used by \code{\link{pmcSupp}} to read supplmentary tables in a variety of formats including Excel, Word, HTML, PDF, text, and zip. If pmc=TRUE, the url string is generated using the PMC id and the file name  http://www.ncbi.nlm.nih.gov/pmc/articles/<pmcid>/bin/<supplementary file>.  If pmc=FALSE, then include the full url string in the file name.

}
\value{
A data.frame or vector for PDF files.
}
% \references{ }
\author{ Chris Stubben }

\note{ May not work on all systems.  Zip files are uncompressed using the unix \code{unzip} command. Excel files are read using the \code{read.xls} function in the gdata package. Microsoft Word documents are converted to html files using the Universal Office Converter \code{unoconv} and then tables within the html files are read using \code{readHTMLtable} in the XML package. The tables within HTML files are also loaded using \code{readHTMLtable}. PDF files are converted to text using the unix script\code{ pdftotext} and the resulting file is read into R using \code{readLines}.
}


\seealso{ \code{\link{pmcSupp}} }
\examples{

\dontrun{
doc <- pmcOAI("PMC2231364" )
pmcSupp(doc)  # list files
# pmcSupp(doc, 3)  # OR
s2 <- getSupp(doc, "1471-2180-7-96-S3.pdf" )
s2
}

}


\keyword{ methods }

