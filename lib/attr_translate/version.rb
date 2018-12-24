module AttrTranslate
  module Version
    Major       = 1
    Minor       = 0
    Revision    = 1
    Prerelease  = nil
    Compact     = [Major, Minor, Revision, Prerelease].compact.join('.')
    Summary     = "AttrTranslate v#{Compact}"
    Description = "Rails concern for ActiveRecord attribute translation using PostgreSQL's JSONB datatype."
    Author      = "Jurgen Jocubeit"
    Email       = "support@brightcommerce.com"
    Homepage    = "https://github.com/brightcommerce/attr_translate"
    Metadata    = {'copyright' => 'Copyright 2018 Brightcommerce, Inc. All Rights Reserved.'}
    License     = "MIT"
  end
end
