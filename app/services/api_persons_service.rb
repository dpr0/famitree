# frozen_string_literal: true

class ApiPersonsService

  attr_reader :persons

  def initialize(persons, relations)
    @persons   = persons
    @relations = relations
  end

  def find(id)
    @tree_persons = []
    @top_relations = []
    @bottom_relations = []
    add_parents(id)
    add_childs(id)
    {
      root_person_id:                            id,
      persons:                   @tree_persons.uniq,
      top_relations:       @top_relations.uniq,
      bottom_relations: @bottom_relations.uniq
    }
  end

  private

  def add_parents(id)
    pp = @persons.find { |x| x.id == id }
    return unless pp

    father   = @persons.find   { |x| x.id == pp.father_id } if pp.father_id
    mother   = @persons.find   { |x| x.id == pp.mother_id } if pp.mother_id
    relation = @relations.find { |x| (pp.sex_id == Sex[:male].id ? x.person_id : x.persona_id) == id }
    @tree_persons << person_info(pp)
    @tree_persons << person_info(@persons.find { |x| x.id == relation.person_id  }) if relation
    @tree_persons << person_info(@persons.find { |x| x.id == relation.persona_id }) if relation
    @top_relations << { from: relation.person_id, to: relation.persona_id, horizontal: true } if relation
    @top_relations << { from: id, to: father.id, horizontal: false } if father
    @top_relations << { from: id, to: mother.id, horizontal: false } if mother
    add_parents(father.id) if father
    add_parents(mother.id) if mother
  end

  def add_childs(id)
    pp = @persons.find { |x| x.id == id }
    return unless pp

    relation = @relations.find { |x| (pp.sex_id == Sex[:male].id ? x.person_id : x.persona_id) == id }
    @tree_persons << person_info(@persons.find { |x| x.id == relation.person_id  }) if relation
    @tree_persons << person_info(@persons.find { |x| x.id == relation.persona_id }) if relation
    @bottom_relations << { from: id, to: pp.sex_id == Sex[:male].id ? relation.persona_id : relation.person_id, horizontal: true } if relation
    @tree_persons << person_info(pp)
    chs = @persons.select { |x| (pp.sex_id == Sex[:male].id ? x.father_id : x.mother_id) == pp.id }
    chs.each do |ch|
      @bottom_relations << { from: id, to: ch.id, horizontal: false }
      add_childs(ch.id)
    end
  end

  def person_info(pp)
    person = pp.slice(:id, :last_name, :first_name, :middle_name, :maiden_name, :sex_id, :birthdate, :deathdate, :avatar_url).symbolize_keys
    person[:confirmed_data] = pp.confirmed_last_name && pp.confirmed_first_name && pp.confirmed_middle_name &&
        pp.confirmed_birthdate && pp.confirmed_deathdate  && pp.confirmed_maiden_name
    person[:additional_branch] = false # TODO
    person
  end
end
