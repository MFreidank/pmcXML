\name{findSpecies}
\alias{findSpecies}

\title{  Find species names  }
\description{ Find species in italics within PMC XML documents }
\usage{
findSpecies(doc )
}

\arguments{
  \item{doc}{ XML document from PMC }
}
\details{  Finds text within italic tags and then checks for possible species by matching two words starting with a capital letter, excluding some common terms like "P value" and "In silico".  Also replaces genus abbreviations by matching species names using \code{\link{unabbrev}}
}
\value{ A vector of species names }
% \references{ }
\author{ Chris Stubben }
% \note{}


\seealso{
 \code{\link{unabbrev}}
}
\examples{
\dontrun{
doc <- pmcOAI("PMC2231364" )
table2(findSpecies(doc))
}
}
\keyword{ methods }

