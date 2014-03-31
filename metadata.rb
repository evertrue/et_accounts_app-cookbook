name             'et_accounts_app'
maintainer       'EverTrue, Inc.'
maintainer_email 'jeff@evertrue.com'
license          'Apache 2.0'
description      'Installs/Configures et_accounts_app'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

depends 'yum',     '~> 3.1'
depends 'apt',     '~> 2.3'
depends 'apache2', '~> 1.9'
depends 'et_users'
depends 'node',    '~> 1.1'
