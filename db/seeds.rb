# frozen_string_literal: true

Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].each { |seed| load seed }

RelationType.create(code: 'married',   name: 'женаты')
RelationType.create(code: 'divorced',  name: 'разведены')

Role.create(code: 'owner',   name: 'Владелец')
Role.create(code: 'editor',  name: 'Редактор')
Role.create(code: 'guest',   name: 'Гость')

Sex.create(code: 'male',     name: 'муж.')
Sex.create(code: 'female',   name: 'жен.')
