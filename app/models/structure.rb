class Structure < ApplicationRecord
  include CacheIt
  has_many :original_properties, class_name: 'Property', dependent: :destroy
  has_many :original_examples, class_name: 'Example'

  has_many :original_building_blocks, foreign_key: 'explained_structure_id',
             inverse_of: :explained_structure, class_name: 'BuildingBlock'

  has_many :atoms, as: :stuff_w_props, dependent: :destroy
  belongs_to :derives_from,
             class_name: 'Structure',
             foreign_key: 'derives_from_id',
             optional: true

  has_many :children, class_name: 'Structure', foreign_key: 'derives_from_id',
           inverse_of: :derives_from

  has_many :axioms, dependent: :destroy
  has_many :defining_atoms, through: :axioms, source: :atom,
           dependent: :destroy

  has_many :implications, dependent: :destroy

  after_commit :touch_examples

  translates :name, :definition, fallbacks_for_empty_translations: true
  globalize_accessors
  # note that the following only works on creation
  validates :name, presence: true

  def structure
    self
  end

  def stuff_id
    "s-#{id}"
  end

  def positive_defining_atoms
    axioms.where(value: true).map(&:atom)
  end

  def negative_defining_atoms
    axioms.where(value: false).map(&:atom)
  end

  def properties
    return original_properties if derives_from.nil?
    original_properties + inherited_properties
  end

  def inherited_properties
    derives_from.properties
  end

  def properties_select(bb)
    original = descendants.map(&:original_properties).flatten.uniq
                          .map { |p| [p.name, p.to_atom(bb).id] }
    return [:ungrouped, original] if derives_from.nil?
    derived = inherited_properties.map { |p| [p.name, p.to_atom(bb).id] }
    return [:ungrouped, derived] if original.nil?
    [:grouped, [[I18n.t('examples.find.direct_properties'), original],
                [I18n.t('examples.find.inherited_properties'), derived]]]
  end


  def properties_as_atoms
    properties.map(&:to_atom)
  end
  cache_it :properties_as_atoms

  def building_blocks
    return original_building_blocks if derives_from.nil?
    original_building_blocks + derives_from.building_blocks
  end

  def related_structures
    result = []
    tmp = [self]
    while result != tmp
      result = tmp
      tmp += tmp.map(&:derives_from).flatten.compact
      tmp += tmp.map(&:children).flatten.compact
      tmp = tmp.flatten.compact.uniq
    end
    result
  end

  def descendants
    result = []
    tmp = [self]
    while result != tmp
      result = tmp
      tmp += tmp.map(&:children).flatten.compact
      tmp = tmp.flatten.compact.uniq
    end
    result
  end

  def building_blocks_flattened
    return [] unless building_blocks.any?
    result = building_blocks
    result += building_blocks.map do |bb|
      bb.structure.building_blocks_flattened
    end
    result.flatten
  end

  def duplicate_building_blocks
    building_blocks_flattened.group_by { |e| e }.select { |k, v| v.size > 1 }
                             .map(&:first)
  end

  def deep_building_blocks_properties_select
    start_blocks = [self]
    start_blocks += [derives_from] if derives_from.present?
    (start_blocks + building_blocks_flattened).uniq.map do |x|
      [x.stuff_id, x.structure.descendants.map(&:properties).flatten.uniq
                    .map { |p| [p.name, p.id] }]
    end .to_h
  end

  def eligible_for_premise_select
    ([self] + building_blocks_flattened).uniq.map { |x| [x.name, x.stuff_id] }
  end

  def eligible_for_axiom_select
    result = building_blocks_flattened.map { |x| [x.name, x.stuff_id] }
    return result unless derives_from.present?
    [[derives_from.name, derives_from.stuff_id]] + result
  end

  def examples
    candidates = related_structures.map(&:original_examples).flatten
    valid_candidates = candidates.select { |e| e.valid? }
    invalid_candidates = candidates - valid_candidates
    valid_examples = valid_candidates.select do |e|
      (axioms.where(value: true).map(&:atom_id) - e.satisfied_atoms_by_sat.map(&:id)).empty? &&
        (axioms.where(value: false).map(&:atom_id) - e.violated_atoms_by_sat.map(&:id)).empty?
    end
    valid_examples + invalid_candidates
  end

  def touch_examples
    Example.where(id: (examples + original_examples).uniq.map(&:id))
           .update_all(updated_at: Time.now)
  end

  def original_implications
    implications.where(parent_implication: nil)
  end

  # returns the array of all building blocks that need to be realized in
  # order have a well-defined example for this structure
  def example_building_blocks
    result = original_building_blocks.to_a
    return result unless derives_from.present?
    result + derives_from.example_building_blocks
  end

  def example_bb_facts
    result = []
    example_building_blocks.each do |bb|
      bb.structure.original_properties.each do |p|
        result.push(Atom.find_or_create_by(stuff_w_props: bb,
                                           satisfies: p))
      end
    end
    result.uniq
  end

  def example_building_block_realizations
    hash = {}
    example_building_blocks.each do |bb|
      relevant_axioms = axioms.select { |ax| ax.atom.stuff_w_props == bb }.map do |axiom|
        [Atom.find_or_create_by(stuff_w_props: bb.structure,
                                satisfies: axiom.atom.satisfies),
         axiom.value]
      end
      realizations = bb.structure.examples.select do |e|
        relevant_axioms.select { |a| a.second }.all? { |a| e.satisfies?(a.first) } &&
          relevant_axioms.reject { |a| a.second }.all? { |a| e.violates?(a.first) }
      end
      hash[bb.id] = realizations
    end
    hash
  end

  def inherited_implications
    implications.where.not(parent_implication: nil)
  end

  # for a locked structure, building blocks and axioms cannot be added,
  # destroyed or modified (except for the building block's name and
  # notation)
  # a structure becomes locked as soon as
  # - an example exists for itself
  # - one of its children is locked
  # implicitly, it will also be locked if one of the structures that has the
  # given structure as a building block is locked, because of the necessity to
  # specify building block realizations for examples
  def locked?
    return true if original_examples.any?
    return true if children.any? { |d| d.locked? }
    false
  end
end
