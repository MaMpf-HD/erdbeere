# ExampleSatisfier worker
class ExampleSatisfier
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(example_id)
    example = Example.find(example_id)
    example.satisfied_atoms_with_proof
    example.satisfied_atoms
  end
end