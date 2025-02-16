# ExampleViolator worker
class ExampleViolator
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(example_id)
    example = Example.find(example_id)
    example.violated_atoms_with_proof
    example.violated_atoms
  end
end