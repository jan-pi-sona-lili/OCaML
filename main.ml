(** OCaML - Machine Learning with OCaml. Uses the {{: https://nn.cs.utexas.edu/downloads/papers/stanley.ec02.pdf} NEAT } algorithm. *)

module Parameter_types = struct
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


        module type Userdata = sig
                type t
                val userdata : t -> float
        end
        (** Turns userdata about a network into its fitness. *)
end 


module Genotype = struct
        type node =
                { id   : int
                ; kind : [ `Sensor | `Hidden | `Output ]
                }

        type connection =
                { in_node  : int
                ; out_node : int
                ; weight   : float
                ; enabled  : bool
                ; innov    : int
                }

        type t = 
                { nodes       : node list
                ; connections : connection list
                }
end

module Phenotype = struct
        module M = Map.Make(struct 
                open Genotype
                type t = node
                let compare {id=id1;_} {id=id2;_} = Int.compare id1 id2
        end)

        let of_genotype Genotype.{nodes;connections} =
                let open Genotype in
                let rec aux set connections = function
                | []   -> set
                | ({id;_} as node)::nodes ->
                                let yes, no = List.partition (fun {in_node;_} -> id = in_node) connections in
                                aux (M.add node yes set) no nodes
                in
                aux M.empty connections nodes 
end

let a = Phenotype.of_genotype Genotype.
        { nodes = 
                [ 
                        { id=1
                        ; kind=`Sensor
                        }
                        ;

                        { id=2
                        ; kind=`Output
                        }
                        ;
                ]
        ;
        connections = 
                [
                        { in_node=1
                        ; out_node=4
                        ; weight=0.5
                        ; enabled=true
                        ; innov=1 
                        }
                        ;
                        
                        { in_node=1
                        ; out_node=2
                        ; weight=0.5
                        ; enabled=true
                        ; innov=1 
                        }
                        ;

                        { in_node=1 (* might need to fix? *)
                        ; out_node=2
                        ; weight=0.5
                        ; enabled=true
                        ; innov=1 
                        }
                ]
        }

let () = Phenotype.M.find Genotype.{id=1;kind=`Sensor} a |> List.iter Genotype.(fun {in_node;out_node;_} -> Printf.printf "in_node = %d; out_node = %d\n" in_node out_node)
