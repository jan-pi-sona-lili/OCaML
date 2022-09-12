(** OCaML - Machine Learning with OCaml. Uses the {{: https://nn.cs.utexas.edu/downloads/papers/stanley.ec02.pdf} NEAT } algorithm. *)

type connection = {
                enabled  : bool;
                out_node : int;
                weight   : float;
                innov    : int; (** innovation number - see section 3.2 in the paper for details. *)
} (** connection - describes a connection. note that it is slightly different compared to the paper's connection description, [{in_node:int; out_node:int; weight:float; enabled:bool; innovation:int}]. this is because the in_node is stored in its containing {{!type:node} node}, which reduces redundancy. *)

type kind       = Sensor | Hidden | Output
type node       = {
                connections : (int, connection) Hashtbl.t;
                kind        : kind;
}
(** Node - contains {{!type:connection} connections}. Note that it is slightly different compared to the paper's specification, [(int,kind)] (where [int] is the ID of the node). This is because the ID of the node is stored in the {{!type:genome} genome} itself, which reduces redundancy. *)

type genome     = {
                sensors : node array;
                hiddens : (int, node) Hashtbl.t;
                outputs : node array;
} (** Genome - contains all the nodes of a network. [sensors] and [outputs] are arrays (fixed size, mutable elements), as their size is known at network creation time, while [hiddens] must be able to grow (and is thus a hashtable). *)

type 'a network = {
                genome : genome;
                mutable innovation : int; (** innovation number - see section 3.2 in the paper for details. *)

                mutable userdata : 'a array; (** holds user-specific information about a network. *)
} (** Network - contains network-specific information. [userdata] contains network-specific user values (for example, position). *)

type 'a parameters = {
        fitness_function     : 'a network -> int; (** fitness function - takes a network and returns its fitness. *)
        input_function       : 'a network -> int list; (** input function - returns a list that is mapped onto the {{!field:genome.sensors} sensor nodes} of a network's genome. *)
        activation_function  : float -> float; (** activation function - see {: https://en.wikipedia.org/wiki/Activation_function}. *)

        weight_mutation_rate     : float;
        connection_mutation_rate : float;
        node_mutation_rate       : float;

        coefficient1 : float; (** these three coefficients adjust the weights in the network distance function {i delta}. See section 3.3 in the paper for details. *)
        coefficient2 : float;
        coefficient3 : float;

        default_userdata : 'a list; (** new networks' {{!field:network.userdata} userdata} are initialized with this. *)
} (** Parameters - describes various parameters of the model. *)

type 'a model   = {
                networks   : 'a network array;
                parameters : 'a parameters;
} (** Model - contains all information about the model, including networks and parameters. *)
