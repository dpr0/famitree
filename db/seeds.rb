# frozen_string_literal: true

Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].each { |seed| load seed }
