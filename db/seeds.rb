# frozen_string_literal: true

Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].each { |seed| load seed }

RelationType.create(code: 'married',   name: 'брак')
RelationType.create(code: 'divorced',  name: 'развод')

Role.create(code: 'owner',   name: 'Владелец')
Role.create(code: 'editor',  name: 'Редактор')
Role.create(code: 'guest',   name: 'Гость')

Sex.create(code: 'male',     name: 'муж.')
Sex.create(code: 'female',   name: 'жен.')

InfoType.create(code: 'disease',           name: 'болезнь')
InfoType.create(code: 'idols',             name: 'кумиры')
InfoType.create(code: 'interests',         name: 'личность и интересы')
InfoType.create(code: 'food',              name: 'любимая еда')
InfoType.create(code: 'music_books',       name: 'музыка, книги')
InfoType.create(code: 'films',             name: 'фильмы')
InfoType.create(code: 'quotes',            name: 'цитаты')
InfoType.create(code: 'politics',          name: 'политика')
InfoType.create(code: 'employer',          name: 'работодатель')
InfoType.create(code: 'religion',          name: 'религия')
InfoType.create(code: 'occupation',        name: 'род занятий')
InfoType.create(code: 'sport',             name: 'спорт')
InfoType.create(code: 'hobbies',           name: 'увлечения')
InfoType.create(code: 'academic_degree',   name: 'ученая степень')
InfoType.create(code: 'hobby',             name: 'хобби')
InfoType.create(code: 'language',          name: 'язык общения')

RelationshipType.create(code: 'husband',   name: 'муж')
RelationshipType.create(code: 'wife',      name: 'жена')
RelationshipType.create(code: 'son',       name: 'сын')
RelationshipType.create(code: 'daughter',  name: 'дочь')
RelationshipType.create(code: 'brother',   name: 'брат')
RelationshipType.create(code: 'sister',    name: 'сестра')
RelationshipType.create(code: 'father',    name: 'отец')
RelationshipType.create(code: 'mother',    name: 'мать')
