# Load the rails application
require File.expand_path('../application', __FILE__)
require File.expand_path('../../lib/core_extensions', __FILE__)

# Initialize the rails application
Koliber::Application.initialize!
PL_DAYS = [nil,'poniedziałek','wtorek','środa','czwartek','piatek','sobota','niedziela']
PL_MONTHS = [nil,'stycznia','lutego','marca','kwietnia','maja','czerwca','lipca','sierpnia','września','października','listopada','grudnia']
