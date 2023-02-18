(** OCaML - Machine Learning with OCaml. Uses the {{: https://nn.cs.utexas.edu/downloads/papers/stanley.ec02.pdf} NEAT } algorithm. *)

module Network_parameter_types = struct
        type threshold_weights =
                { excess       : float
                ; disjoint     : float
                ; network_diff : float
                }
        (** Coefficients for adjusting how strongly a given factor affects the speciation threshold. *)

        type network_dimensions =
                { sensors : int
                ; outputs : int
                }
        (** Size of the network's input and output. *)

        type mutation_rates =
                { add_node          : float
                ; add_connection    : float
                ; modify_connection : float
                }
        (** How often a given mutation happens. *)
end 

module type Userdata = sig
        type t
        val fitness : t -> float
end

module Model : sig
        type t
        val make :
                ?activation        : (float -> float) ->
                threshold_weights  : Network_parameter_types.threshold_weights ->
                network_dimensions : Network_parameter_types.network_dimensions ->
                mutation_rates     : Network_parameter_types.mutation_rates ->
                network_count      : int ->
                userdata           : (module Userdata) -> 
                unit -> 
                t
end = struct 
        module type IN = sig
                include Userdata
                val activation         : float -> float 
                val threshold_weights  : Network_parameter_types.threshold_weights
                val network_dimensions : Network_parameter_types.network_dimensions
                val mutation_rates     : Network_parameter_types.mutation_rates
                val network_count      : int 
                val fitness            : t -> float
        end
        module type OUT = sig
        end

        type t = (module OUT)

        module ModelF(M : IN) : OUT = M

        let make
                ?(activation=fun x -> Float.(1. /. (1. +. (exp @@ neg x))))
                ~threshold_weights
                ~network_dimensions
                ~mutation_rates
                ~network_count
                ~userdata
                ()
        =
                let module M = ModelF(struct 
                        include (val userdata : Userdata)
                        let activation = activation
                        let threshold_weights = threshold_weights
                        let network_dimensions = network_dimensions
                        let mutation_rates = mutation_rates
                        let network_count = network_count
                        let fitness = fitness
                end) in (module M : OUT)
end
