# frozen_string_literal: true

Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].each { |seed| load seed }

RelationType.create(code: 'father',   name: 'Отец')
RelationType.create(code: 'mother',   name: 'Мать')
RelationType.create(code: 'wife',     name: 'Жена')
RelationType.create(code: 'husband',  name:  'Муж')
RelationType.create(code: 'sister',   name:  'Сын')
RelationType.create(code: 'brother',  name: 'Дочь')
