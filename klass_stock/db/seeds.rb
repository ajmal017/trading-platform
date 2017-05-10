Sector.create([
  {:name => 'Agro & Food Industry', :symbol => 'AGRO'},
  {:name => 'Consumer Products', :symbol => 'CONSUMP'},
  {:name => 'Financials', :symbol => 'FINCIAL'},
  {:name => 'Industrials', :symbol => 'INDUS'},
  {:name => 'Property & Construction', :symbol => 'PROPCON'},
  {:name => 'Resources', :symbol => 'RESOURC'},
  {:name => 'Services', :symbol => 'SERVICE'},
  {:name => 'Technology', :symbol => 'TECH'}
])

Industry.create([
  {:sector_id => 1, :name => 'Agribusiness', :symbol => 'AGRI'},
  {:sector_id => 1, :name => 'Food and Beverage', :symbol => 'FOOD'},

  {:sector_id => 2, :name => 'Fashion', :symbol => 'FASHION'},
  {:sector_id => 2, :name => 'Home & Office Products', :symbol => 'HOME'},
  {:sector_id => 2, :name => 'Personal Products & Pharmaceuticals', :symbol => 'PERSON'},

  {:sector_id => 3, :name => 'Banking', :symbol => 'BANK'},
  {:sector_id => 3, :name => 'Finance and Securities', :symbol => 'FIN'},
  {:sector_id => 3, :name => 'Insurance', :symbol => 'INSUR'},

  {:sector_id => 4, :name => 'Automotive', :symbol => 'AUTO'},
  {:sector_id => 4, :name => 'Industrial Materials & Machinery', :symbol => 'IMM'},
  {:sector_id => 4, :name => 'Paper & Printing Materials', :symbol => 'PAPER'},
  {:sector_id => 4, :name => 'Petrochemicals & Chemicals', :symbol => 'PETRO'},
  {:sector_id => 4, :name => 'Packaging', :symbol => 'PKG'},
  {:sector_id => 4, :name => 'Steel', :symbol => 'STEEL'},

  {:sector_id => 5, :name => 'Construction Materials', :symbol => 'CONMAT'},
  {:sector_id => 5, :name => 'Property Development', :symbol => 'PROP'},
  {:sector_id => 5, :name => 'Property Fund', :symbol => 'PFUND'},

  {:sector_id => 6, :name => 'Energy & Utilities', :symbol => 'ENERG'},
  {:sector_id => 6, :name => 'Mining', :symbol => 'MINE'},

  {:sector_id => 7, :name => 'Commerce', :symbol => 'COMM'},
  {:sector_id => 7, :name => 'Health Care Services', :symbol => 'HELTH'},
  {:sector_id => 7, :name => 'Media & Publishing', :symbol => 'MEDIA'},
  {:sector_id => 7, :name => 'Professional Services', :symbol => 'PROF'},
  {:sector_id => 7, :name => 'Tourism & Leisure', :symbol => 'TOURISM'},
  {:sector_id => 7, :name => 'Transportation & Logistics', :symbol => 'TRANS'},

  {:sector_id => 8, :name => 'Electronic Components', :symbol => 'ETRON'},
  {:sector_id => 8, :name => 'Information & Communication Technology', :symbol => 'ICT'}
])
