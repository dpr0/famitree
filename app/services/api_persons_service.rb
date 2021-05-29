# frozen_string_literal: true

class ApiPersonsService

  attr_reader :persons

  def initialize(persons, relations)
    @persons   = persons
    @relations = relations
  end

  def find(id)
    @top_tree_persons = []
    @top_tree_relations = []
    add_fa_mo(id)
    @bottom_tree_persons = []
    @bottom_tree_relations = []
    add_childs(id)
    {
      root_person_id:               id,
      top_tree_persons:           @top_tree_persons,
      top_tree_relations:       @top_tree_relations,
      bottom_tree_persons:     @bottom_tree_persons,
      bottom_tree_relations: @bottom_tree_relations
    }
  end

  private

  def add_fa_mo(id)
    pp = @persons.find { |x| x.id == id }
    return unless pp
    father   = @persons.find   { |x| x.id == pp.father_id } if pp.father_id
    mother   = @persons.find   { |x| x.id == pp.mother_id } if pp.mother_id
    relation = @relations.find { |x| x.person_id == father.id && x.persona_id == mother.id } if father && mother
    @top_tree_persons << person_info(pp)
    @top_tree_relations << { from: relation.person_id, to: relation.persona_id, horizontal: true } if relation
    @top_tree_relations << { from: id, to: father.id, horizontal: false } if father
    @top_tree_relations << { from: id, to: mother.id, horizontal: false } if mother
    add_fa_mo(father.id) if father
    add_fa_mo(mother.id) if mother
  end

  def add_childs(id)
    pp = @persons.find { |x| x.id == id }
    return unless pp
    relation = @relations.find { |x| pp.sex_id == Sex[:male].id ? x.person_id : x.persona_id == id }
    @bottom_tree_relations << { from: id, to: pp.sex_id == Sex[:male].id ? relation.persona_id : relation.person_id, horizontal: true } if relation
    @bottom_tree_persons << person_info(pp)
    chs = @persons.select { |x| (pp.sex_id == Sex[:male].id ? x.father_id : x.mother_id) == pp.id }
    chs.each do |ch|
      @bottom_tree_relations << { from: id, to: ch.id, horizontal: false }
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
