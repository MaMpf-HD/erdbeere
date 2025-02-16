[![Code Climate](https://codeclimate.com/github/oqpvc/erdbeere/badges/gpa.svg)](https://codeclimate.com/github/oqpvc/erdbeere)
[![Build Status](https://travis-ci.org/oqpvc/erdbeere.svg?branch=master)](https://travis-ci.org/oqpvc/erdbeere)

# erdbeere

ErDBeere is short for “Erkenntnisfördernde Datenbank zur Beispielerfassung und
-entwicklung” (informative database for the development and management of
examples) and should be thought of as an e-learning tool for higher (i. e.,
University level) mathematics.

It aims to store mathematical examples somewhat like
the [ring database](http://ringtheory.herokuapp.com) and is supposed to help
students explore features of mathematical objects. Consider the following
questions:

- What does a principal ideal domain that is not Euclidean look like?
- What does a quasi-projective and proper morphism between schemes look like,
  that isn't projective?
- Is there a ring that is a principal ideal domain, but not a unique
  factorization domain?

The first question has a simple enough answer with the ring of integers of
$\mathbb{Q}(\sqrt{-19})$. The second also has an example as the answer, but it is worthwhile
to know that every quasi-projective proper morphism $X\to Y$ is projective if $Y$ is
qcqs. The third question of course has no example at all, as every principal
ideal domain is a UFD.

ErDBeere wants to represent all the data in the answers above, i.e., *concrete
examples* and *abstract implications*, in the nicest possible manner.

## Local Installation

Local installation is easiest via docker. Just run

```sh
cd docker/development
docker compose up
```
This should set up a container called `erdbeere`
that you can reach at `http://localhost:3005`.
If you do this for the first time, the database will still be empty. In that case you can enter the container and seed the database:

```sh
docker exec -it erdbeere bash
rails db:migrate
rails db:seed
```
This will generate a user with email `admin@mampf.edu` and password `dockermampf`.
On slower machines, seeding might take a while. If it takes too long for your taste, just reduce the number of examples seeded, e.g. by making the array over which appears in line 13 of `db/seeds.db` smaller. If you do not want to use the seed file and still set up a user, just run

```sh
docker exec -it erdbeere rails c # This opens a rails console inside the container
User.create(email: "your@favorite.mail", password: "whateveryoulike")
```

## Data Structures

We will explain the internal data structures using example pieces of code.

### Categories, Properties and Implications

```ruby
ring = Structure.create do |s|
  s.name = 'Ring'
  s.definition = 'A ring $R$ is an abelian group together with a ' +
                 'map $R\times R …'
end

unitary = Property.create do |p|
  p.name = 'unitary'
  p.structure = ring
  p.definition = '…'
end

# …

l_noeth = Property.create(name: 'left Noetherian', structure: ring)
r_noeth = Property.create(name: 'right Noetherian', structure: ring)
comm = Property.create(name: 'commutative', structure: ring)
vnr = Property.create(name: 'von Neumann regular (aka absolutely flat)',
                        structure: ring)

```

Rings are easy classes of objects to represent, as they don't depend on other
structures. But as soon as $R$-modules enter the picture, this becomes decidedly
more complicated, as their properties may depend on their base ring.
Structures can hence have building blocks.

```ruby
rmod = Structure.create(name: '$R$-(left-)Module')
base_ring = BuildingBlock.create(name: 'base ring',
                                   explained_structure: rmod,
                                   structure: ring, definition: 'A ' +
                                   'ring homomorphism $R\longrightarrow ' +
                                   '\mathrm{End}(M)$ …')
```

Now we want to encode the following result: “A finitely generated
$R$-left-module over a left Noetherian ring is itself Noetherian”.

```ruby
fin_gen = Property.create(name: 'finitely generated', structure: rmod)
noeth_module = Property.create(name: 'ascending chain condition for ' +
                               'submodules', structure: rmod)

base_ring_is_lnoeth = Atom.create(stuff_w_props: base_ring, satisfies:
                                   l_noeth)
module_is_fg = Atom.create(stuff_w_props: rmod, satisfies: fin_gen)
module_has_acc = Atom.create(stuff_w_props: rmod, satisfies: noeth_module)

[module_is_fg, base_ring_is_lnoeth].implies! module_has_acc
```

### Examples

An example for a structure in the sense above depends on examples of all of its
building blocks (e. g., for an $R$-module we first need a ring $R$). Consider
the following code snippet:

```ruby
zee = Example.create(structure: ring)
zee.satisfies! [comm, l_noeth]
zee.violates! vnr

zee_r = Example.create(structure: rmod)
BuildingBlockRealization.create(example: zee_r, building_block:
  base_ring, realization: zee)
zee_r.satisfies! module_is_fg
```

### The logic engine

The logic engine makes use of the SATSolver [picosat](https://fmv.jku.at/picosat/) with enabled trace generation.
The obtained results are then translated to human-readable proofs.

### The GUI

The GUI makes use of bootstrap.
