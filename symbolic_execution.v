Require Import Ensembles. 
Require Import Logic.

Module ConcState.


(*Variable input : Type.
Variable variable: Type.
Variable conc_state : Type.*)


Variable input_variable : Type.
Variable variable : Type.
Variable concrete_value : Type.
Variable map_alphabet : Type.
Variable concrete_expression : Type.

Inductive conc_state_tuple : Type :=
|consConc (r : variable) (cv : concrete_value).



Inductive conc_input_tuple : Type :=
|consCInp (ia : input_variable) (cv : concrete_value).




(*Inductive conc_ex_input : Type :=
|ConsTuple  (cs : conc_state) (i :input).*)



Definition get_conc_val ( c : conc_state_tuple) : concrete_value :=
match c with 
|consConc r cv => cv
end.

Definition get_conc_inp_val ( c : conc_input_tuple) : concrete_value :=
match c with 
|consCInp ia cv => cv
end.



Definition get_conc_variable ( c : conc_state_tuple) : variable :=
match c with 
|consConc r cv => r
end.

Definition get_conc_inp_assignment ( c : conc_input_tuple) : input_variable :=
match c with 
|consCInp ia cv => ia
end.


(*Definition get_variable ( s : state_var) : variable :=
match s with 
|ConsTuple i sa => sa
end.*)


(*Inductive conc_state : Type :=
|EmptyState
|ConsState (i: input) (s: state).*)

(*Definition concrete_execution :=  conc_ex_input ->  conc_state.
Axiom conc_ex : concrete_execution.*)

Definition concrete_execution :=  list conc_state_tuple -> list conc_input_tuple ->  list conc_state_tuple.
Axiom conc_ex : concrete_execution.

(*Definition concrete_execution_many := conc_state -> input -> conc_state.
Axiom conc_ex_many : concrete_execution_many.*)

End ConcState.
Import ConcState.

Module SymbolicExec.

Variable Phi : Type.
Variable symbolic_alphabet : Type.
Variable symbolic_expression : Type.

Definition mta := symbolic_alphabet -> ConcState.map_alphabet.
Axiom map_to_alphabet : mta.

Inductive sym_state: Type :=
|ConstructState (a : Phi) (pc : symbolic_expression)
|nilstate.

Inductive sym_state_tuple : Type :=
|consSym (r : ConcState.variable) (se : symbolic_expression).

Inductive sym_input_tuple : Type :=
|consSInp (ia : ConcState.input_variable) (se : symbolic_expression).

Definition get_sym_exp ( s : sym_state_tuple) : symbolic_expression :=
match s with 
|consSym r se => se
end.

Definition get_inp_sym_exp ( s : sym_input_tuple) : symbolic_expression :=
match s with 
|consSInp ia se => se
end.

Definition get_sym_variable ( s : sym_state_tuple) : ConcState.variable :=
match s with 
|consSym r se => r
end.

Definition get_sym_inp_assignment ( s : sym_input_tuple) : ConcState.input_variable :=
match s with 
|consSInp ia se => ia
end.

Definition and := symbolic_expression -> symbolic_expression -> symbolic_expression.
Axiom logical_and : and.

(*** SYM STATE STRUCTURE ***)

(* get_phi returns abstract state *)
(*Definition get_sym_state  :=  sym_state -> Phi.
Axiom get_phi : get_sym_state.*)

(* get_pc returns the path constraint *)
(*Definition get_path_constraint := sym_state -> PC.
Axiom get_pc : get_path_constraint.*)

Inductive node_tuple : Type :=
|consNode (ls : list sym_state_tuple) (pc : symbolic_expression).


Definition get_sym_state ( n : node_tuple) : list sym_state_tuple:=
match n with
|consNode s pc => s
end.

Definition get_pc ( n : node_tuple) : symbolic_expression:=
match n with
|consNode s pc => pc
end.


(*** SYM EX TREE STRUCTURE ***)

Inductive SE_tree : Type :=
| nilleaf: SE_tree
| ConsNode: SE_tree -> node_tuple -> SE_tree -> SE_tree.


(*Definition root (t : SE_tree) (safety_proof : t <> nilleaf) : node_tuple :=
(match t as b return (t = b -> node_tuple) with 
|nilleaf =>  (fun foo : t = nilleaf => 
                   match (safety_proof foo) return node_tuple with
                   end
                )
|ConsNode l n r => (fun foo : t =ConsNode l n r => 
                   n
                )
end) eq_refl.*)

Definition r :=  SE_tree -> node_tuple.
Axiom root : r.

Definition s_e := list sym_state_tuple -> list sym_input_tuple -> SE_tree.
Axiom sym_ex : s_e.

Axiom root_def : 
forall (s : list sym_state_tuple) (sym_inp : list sym_input_tuple),
get_sym_state (root (sym_ex s sym_inp)) =  s.


Fixpoint is_leaf (s' : node_tuple) (s : SE_tree) : Prop :=
match s with
|ConsNode nilleaf n nilleaf => s' = n
|ConsNode l n r => (is_leaf s' l) \/ (is_leaf s' r)
|nilleaf => False
end.

Fixpoint in_tree (n : node_tuple) (t : SE_tree) : Prop :=
match t with
|nilleaf => False
|ConsNode l x r => x = n \/ (in_tree n l) \/ (in_tree n r)
end.

Fixpoint is_child_of (n1 n2 : node_tuple) (t : SE_tree) :=
match t with 
|nilleaf => False
|ConsNode l x r => (n1 = x /\ (in_tree n2 l \/ in_tree n2 r)) 
                    \/ is_child_of n1 n2 l
                    \/ is_child_of n1 n2 r
end.

(*** SYMBOLIC EXECUTION ***)
(*Definition s_e := sym_state -> SE_tree.
Axiom sym_ex : s_e.

Axiom sym_ex_root : 
forall (t : SE_tree) (s : sym_state),
s = root t <->
t = sym_ex s.*)



(*Definition r_inst_s :=  sym_state -> ConcState.conc_state.
Axiom randomly_instantiate_conc_state : r_inst_s.

Definition r_inst_i := sym_state -> input.
Axiom randomly_instantiate_input : r_inst_i.*)

(*Definition pc_e := PC -> ConcState.variable -> ConcState.input -> Prop.
Axiom pc_eval : pc_e.*)

Definition pc_e := ConcState.concrete_value -> Prop.
Axiom pc_eval : pc_e.

(*Definition c_inst := Phi -> ConcState.variable -> ConcState.input  -> ConcState.conc_ex_input.
Axiom conc_instantiate : c_inst.

Definition s_inst := Phi -> ConcState.variable -> ConcState.input  -> ConcState.conc_state.
Axiom sym_instantiate : s_inst.*)

Definition mtc := symbolic_expression -> ConcState.map_alphabet -> ConcState.concrete_expression.
Axiom map_to_concrete : mtc.

Definition simp := ConcState.concrete_expression -> ConcState.concrete_value. 
Axiom simplify : simp.

Definition instantiate (s : symbolic_expression) (a : symbolic_alphabet) : ConcState.concrete_value :=
simplify (map_to_concrete s (map_to_alphabet a)).

Definition state_instantiate 
(s : sym_state_tuple) (a : symbolic_alphabet) : conc_state_tuple :=
(consConc
  (get_sym_variable s)
 (instantiate (get_sym_exp s) a)).

Definition input_instantiate
( i : sym_input_tuple)  (a : symbolic_alphabet) : conc_input_tuple :=
(consCInp
(get_sym_inp_assignment i)
(instantiate (get_inp_sym_exp i) a)).

Notation "x :: l" := (cons x l) (at level 60, right associativity).

Fixpoint list_state_instantiate 
(ls : list sym_state_tuple)  (a : symbolic_alphabet) : list conc_state_tuple :=
match ls with
|nil => nil
|s :: nil => (consConc
            (get_sym_variable s)
            (instantiate (get_sym_exp s) a)) :: nil
|s :: head => (consConc
            (get_sym_variable s)
            (instantiate (get_sym_exp s) a)) :: (list_state_instantiate head a)
end.

Fixpoint list_input_instantiate
( li : list sym_input_tuple)  (a : symbolic_alphabet) : list conc_input_tuple :=
match li with
|nil => nil
|i :: nil => (consCInp
              (get_sym_inp_assignment i)
              (instantiate (get_inp_sym_exp i) a)) :: nil
|i :: head => (consCInp
              (get_sym_inp_assignment i)
              (instantiate (get_inp_sym_exp i) a)) :: (list_input_instantiate head a)
end.


Axiom sound_paths :
forall (a : symbolic_alphabet) (s : list sym_state_tuple)
(i : list sym_input_tuple) (n : node_tuple),
in_tree n (sym_ex s i)  ->
(pc_eval (instantiate (get_pc n) a)).

Axiom unique_paths : 
forall (a : symbolic_alphabet) (s : list sym_state_tuple)
(i : list sym_input_tuple) (n1 n2 : node_tuple)
( t : SE_tree),
t = sym_ex s i
/\ n1 <> n2
/\ in_tree n1 t
/\ in_tree n2 t
/\ (is_child_of n1 n2 t = False)
/\(is_child_of n2 n1 t = False)
->(pc_eval (instantiate (logical_and (get_pc n1) (get_pc n2)) a)) = False.


Axiom commutativity':
forall 
(li' : list sym_input_tuple) (s : list sym_state_tuple) ( l : node_tuple)
 (a : symbolic_alphabet),
(is_leaf l (sym_ex s li')) /\
(pc_eval (instantiate (get_pc l) a))
-> 
(conc_ex 
(list_state_instantiate s a)
(list_input_instantiate li' a))
= (list_state_instantiate (get_sym_state l) a).




(*** TREE LIST STRUCTURE ***)


Notation "x :: l" := (cons x l) (at level 60, right associativity).

Fixpoint first_elem ( l : list SE_tree) : SE_tree :=
match l with
|nil => nilleaf
|x :: nil => x
|x :: y => first_elem y
end.

Definition front (l : list SE_tree) : list SE_tree :=
match l with
|nil => nil
|x :: y => y
end.

Definition last_elem (l : list SE_tree) : SE_tree :=
match l with
|nil => nilleaf
|x :: y => x
end.

Definition second_last_elem (l : list SE_tree) : SE_tree :=
match l with
|nil => nilleaf
|x :: y => last_elem y
end.

Fixpoint list_size (l : list SE_tree) : nat :=
match l with
|nil => 0
|x :: nil => 1
|x :: y => S (list_size y)
end.

Fixpoint in_list (l : list SE_tree) (t : SE_tree) : Prop :=
match l with
|nil => False
|x :: y => (x = t) \/ (in_list y t)
end.

Fixpoint consecutive_in_order (a b : SE_tree) (l : list SE_tree) : Prop :=
match l with
| h :: t => (a = h /\ b = (last_elem t)) \/ consecutive_in_order a b t
| nil => False
end.

(* Checks if l2 is a prefix of l1*)
Fixpoint is_prefix (l1 l2 : list SE_tree) : Prop :=
match l1 with
|nil => False
|h :: t => (l2 <> nil) /\ ((l2 = l1) \/ (is_prefix t l2))
end.


(*** SET OPERATION SHORT HANDS ***)
Definition is_subset (x y : Ensemble (list ConcState.conc_state_tuple)) : Prop :=
Included (list  ConcState.conc_state_tuple) x y.

Definition is_element_of (y : Ensemble (list ConcState.conc_state_tuple)) (x : list ConcState.conc_state_tuple) : Prop :=
In (list  ConcState.conc_state_tuple) y x.

Definition empty_set : Ensemble (list ConcState.conc_state_tuple) := 
Empty_set (list ConcState.conc_state_tuple).

Definition intersection (x y : Ensemble (list ConcState.conc_state_tuple)) : Ensemble (list ConcState.conc_state_tuple) :=
Intersection (list ConcState.conc_state_tuple) x y.


End SymbolicExec.
Import SymbolicExec. 

Module SERecurs.

Variable init_conc_state: list ConcState.conc_state_tuple.
Variable Error_States : Ensemble (list ConcState.conc_state_tuple).
Variable tree_list : list SE_tree.
Variable alpha : SymbolicExec.symbolic_alphabet.

Axiom no_leaf_requirement:
forall (s : SE_tree),
in_list tree_list s -> s <> nilleaf.

Axiom non_empty : 
tree_list <> nil.

Axiom size_requirement: 
list_size tree_list > 0.

Axiom nil_is_nil:
nilleaf :: nil = nil.

Axiom nil_leaf_elim:
forall l : list SE_tree,
 l <> nil -> (nilleaf :: l) <> nil.

Axiom leaf_elim:
forall (l : list SE_tree) (s : SE_tree),
 l <> nil -> (s :: l) <> nil.

Axiom non_nil_elem_in_list:
forall (l : list SE_tree) (s : SE_tree),
 s <> nilleaf -> (s :: l) <> nil.


Definition fl := SE_tree -> node_tuple.
Axiom find_leaf : fl.

Definition is_l_leaf :=  node_tuple -> SE_tree -> Prop.
Axiom is_list_leaf : is_l_leaf.

Axiom ll_def : 
forall (s: node_tuple) (t : SE_tree),
is_list_leaf s t
-> is_leaf s t.

Axiom ll_def2:
forall (s: node_tuple) (t : SE_tree),
is_list_leaf s t <->
(find_leaf t = s).

Definition gi := SymbolicExec.symbolic_expression -> list ConcState.conc_input_tuple.
Axiom get_input : gi.

(*Definition gi := SymbolicExec.PC -> ConcState.input.
Axiom get_input : gi.

Definition gsa := SymbolicExec.PC -> ConcState.variable.
Axiom get_variable : gsa.*)

Axiom get_input_def :
(*Finds inputs given a pc that satisfy that pc
*)
forall (l : node_tuple) (a : SymbolicExec.symbolic_alphabet) ( i : list sym_input_tuple) , 
((exists (s : list sym_state_tuple) ,
(is_leaf l (sym_ex s i)) /\
(pc_eval (instantiate (get_pc l) a)))) ->
(list_input_instantiate i a)
= (get_input (get_pc l)).

(*** CIRCLE OPERATIONS ***)
(* Takes as input symbolic state of root and pc of its leaf 
and returns all and only the concrete states that will take us down 
the path that leads to the leaf. *)
Definition c_o_1 := SE_tree -> Ensemble (list ConcState.conc_state_tuple).
Axiom circle_op_1 : c_o_1.

Definition c_o_2 := SE_tree -> Ensemble (list ConcState.conc_state_tuple).
Axiom circle_op_2 : c_o_2.


Axiom c_o_1_def : 
forall (t : SE_tree) (cs : list ConcState.conc_state_tuple)
,
is_element_of (circle_op_1 t) cs <->
(*exists (s : sym_state), (s = root t) /\*)
exists (s : list sym_state_tuple) (s' : node_tuple)
 (a : SymbolicExec.symbolic_alphabet)
,
(s = (get_sym_state (root t))) /\
(is_list_leaf s' t) /\
pc_eval (instantiate (get_pc s') a) /\
cs = list_state_instantiate s a.

Axiom c_o_2_def : 
forall (t : SE_tree) (cs: list ConcState.conc_state_tuple)
,
is_element_of (circle_op_2 t) cs <->
exists (s : list sym_state_tuple) (s' : node_tuple) (a : SymbolicExec.symbolic_alphabet)
,
(s = (get_sym_state (root t))) /\
(is_list_leaf s' t) /\
pc_eval (instantiate (get_pc s') a) /\
(cs = list_state_instantiate (get_sym_state s') a).


(*Theorem circle_op_property':
forall (t : SE_tree) 
 (li: ConcState.input) (sa : ConcState.variable)
 (cs : ConcState.conc_state),
(exists s s' : sym_state,
      s = root t /\
      pc_eval (get_pc s') sa li /\
      is_element_of (circle_op_1 t) cs /\
      is_list_leaf s' t /\
      cs = instantiate (get_phi s) sa li)
->is_element_of 
(circle_op_2 t)
(conc_ex cs).
Proof. intros. destruct H. destruct H. apply c_o_2_def.
exists x0. exists x. exists li. exists sa.
destruct H. destruct H0. destruct H1. destruct H2. 
split. apply H. split. apply H2. split. apply H0.
rewrite H3. apply commutativity'. exists t.
apply sym_ex_root in H. split. apply H. split.
 apply ll_def in H2. apply H2. apply H0. Qed.*)


(*Axiom get_input_def : 
forall (t : SE_tree) (li: ConcState.input) 
(sa : ConcState.variable) (cs : ConcState.conc_state),
li = get_input (get_input (get_pc (find_leaf t))) /\
sa =  get_variable (get_input (get_pc(find_leaf t))) /\
cs = (instantiate (get_phi(find_leaf t)) sa li)
->
exists (s s' : sym_state),
s = root t /\
pc_eval (get_pc s') sa li
/\ is_list_leaf s' t.*)


(*

Theorem get_input_def' : 
forall (t : SE_tree) (li: ConcState.input) 
(sa : ConcState.variable) (cs : ConcState.conc_state), 
is_element_of (circle_op_1 t) cs /\ 
li = get_input (get_input (get_pc (find_leaf t))) /\
sa =  get_variable (get_input (get_pc(find_leaf t))) /\
cs = (instantiate (get_phi(find_leaf t)) sa li)
-> 
exists (s s' : sym_state),
s = root t /\
pc_eval (get_pc s') sa li 
/\ is_element_of (circle_op_1 t) cs 
/\ is_list_leaf s' t
/\ cs = (instantiate (get_phi s') sa li).
Proof. intros. 
(*assert (
li = get_input (get_input (get_pc (find_leaf t))) /\
sa =  get_variable (get_input (get_pc(find_leaf t))) /\
cs = (instantiate (get_phi(find_leaf t)) sa li)).*)
destruct H. pose H0 as H1. apply get_input_def in H1.
destruct H1. exists x. destruct H1. exists x0.
 split. destruct H1. apply H1. split. destruct H1.
destruct H2. apply H2.
split. apply H. destruct H0. destruct H2. 
split. destruct H1. destruct H4. apply H5. 
destruct H1. destruct H4. apply ll_def2 in H5. 
rewrite <- H5. apply H3. Qed.

*)

(*Theorem circle_op_property_2':
forall (t : SE_tree)
  (cs cs': ConcState.conc_state),
is_element_of (circle_op_1 t) cs  

->
cs = (instantiate (get_phi(find_leaf t)) 
(get_variable (get_input (get_pc(find_leaf t)))) 
(get_input(get_input (get_pc (find_leaf t))))) /\
is_element_of 
(circle_op_2 t)
(conc_ex cs).
Proof. intros. pose c_o_1_def.
apply c_o_1_def in H.  
apply get_input_def' in H.  
apply circle_op_property' in H. apply H. Qed.*)

(*Axiom ll_def : 
forall xis_list_leaf x t*)


Theorem circle_op_property_2: 
forall (s : list sym_state_tuple) (sym_inp : list sym_input_tuple) 
(x : list ConcState.conc_state_tuple) ,
is_element_of 
(circle_op_1 (sym_ex s sym_inp)) x 
->
is_element_of
  (circle_op_2 (sym_ex s sym_inp))
  (conc_ex x (get_input (get_pc (find_leaf (sym_ex s sym_inp))))).
Proof. intros.  apply c_o_2_def.
apply c_o_1_def in H. 
destruct H. exists x0.
destruct H. exists x1.
destruct H. exists x2.
destruct H. split. apply H.
destruct H0. split. apply H0.
destruct H1. split. apply H1.
assert (list_input_instantiate sym_inp x2 =
   (get_input
     (get_pc
        (find_leaf (sym_ex s sym_inp))))).
apply get_input_def.
exists s. 
split. pose H0 as H3.
apply ll_def2 in H3. rewrite H3.
apply ll_def in H0.
apply H0.
pose H0 as H3.
apply ll_def2 in H3. rewrite H3.
 apply H1.
rewrite H2. 
rewrite <- H3.
apply commutativity'.
apply ll_def in H0. split.
 rewrite root_def in H. rewrite H. apply H0.
apply H1. Qed.

Axiom SE_tree_def : 
forall t : SE_tree, 
exists (s : list sym_state_tuple) (i : list sym_input_tuple),
t = sym_ex s i.

Theorem circle_op_property : 
forall (t : SE_tree),
forall (x : list conc_state_tuple),
is_element_of (circle_op_1 t) x ->
is_element_of (circle_op_2 t)
  (conc_ex x
     (get_input (get_pc (find_leaf t)))).
Proof. intros.
assert (exists (s : list sym_state_tuple) (i : list sym_input_tuple),
t = sym_ex s i). apply SE_tree_def. destruct H0. destruct H0.
rewrite H0.
apply circle_op_property_2. rewrite <- H0. apply H. Qed.




(*** PROPERTIES 1-3 ***)
Definition trees_connect (A B : SE_tree) : Prop :=
is_subset
(circle_op_2 A)
(circle_op_1 B).


Axiom Prop1 : 
is_element_of 
(circle_op_1 (first_elem tree_list)) init_conc_state.

(*Axiom Prop2 : 
intersection 
(circle_op_2 (last_elem tree_list))
Error_States 
<> empty_set.*)

Axiom Prop2':
is_subset
(circle_op_2 (last_elem tree_list))
Error_States.

Axiom Prop3 : 
forall (a b : SE_tree), 
consecutive_in_order a b tree_list ->
trees_connect b a.

(*Axiom Prop3':
forall (a : SE_tree), 
in_list tree_list a ->
(circle_op_2 a) <> empty_set.*)



(*** SUFFICIENCY ***)



Fixpoint execute_tree_list (tlist : list SE_tree) : list ConcState.conc_state_tuple :=
match tlist with
|nil => init_conc_state
|h :: nil => conc_ex (init_conc_state) (get_input (get_pc (find_leaf h)))
|h :: t => conc_ex (execute_tree_list t) (get_input (get_pc(find_leaf h)))
end.


Theorem etl_1_step:
forall (t : list SE_tree) (s : SE_tree),
(list_size t > 0) /\ (list_size (s :: t) > 0) /\ s <> nilleaf ->
execute_tree_list (s :: t) = conc_ex (execute_tree_list t) (get_input(get_pc(find_leaf s))).
Proof. intros.
induction s.
-destruct H. destruct H0. contradiction. 
-induction t.
*destruct H. simpl in H. inversion H.
*simpl; auto.
Qed.


(*** SET PROPERTIES ***)
Theorem set_property_1:
forall (A : list ConcState.conc_state_tuple) (B C : Ensemble (list ConcState.conc_state_tuple)),
(is_element_of B A)
/\ (is_subset B C)
-> (is_element_of C A).
Proof. intros. unfold is_element_of.  destruct H. 
unfold is_subset in H0. unfold Included in H0. 
apply H0.
unfold is_element_of in H. apply H. Qed.

Theorem set_property_2:
forall (A : (list ConcState.conc_state_tuple)) (B C : Ensemble (list ConcState.conc_state_tuple)) (i : list ConcState.conc_input_tuple),
((is_element_of B A)
/\
(forall (x : (list ConcState.conc_state_tuple)),
is_element_of B x
-> is_element_of C (conc_ex  x i))
)
-> is_element_of C (conc_ex A i).
Proof. intros. destruct H. 
apply H0. apply H. Qed.





(*** APPLICATION OF SET PROPERTIES ***)

Theorem P1_and_circle_op_prop:
forall (t : list SE_tree) (i: list ConcState.conc_input_tuple),
((is_element_of 
  (circle_op_1 (last_elem t)) 
  init_conc_state)
/\
(forall (x : list ConcState.conc_state_tuple),
is_element_of 
  (circle_op_1 (last_elem t)) x
-> is_element_of (circle_op_2(last_elem t)) (conc_ex  x i)))
-> is_element_of (circle_op_2(last_elem t)) (conc_ex  init_conc_state i).
Proof. intros. apply set_property_2 in H. apply H. Qed.

Theorem P1_and_circle_op_prop_ind_step:
forall (t : list SE_tree) (i: list ConcState.conc_input_tuple) ,
((is_element_of 
  (circle_op_1 (last_elem t)) 
  (execute_tree_list (front t)))
/\
(forall (x : list ConcState.conc_state_tuple),
is_element_of 
  (circle_op_1 (last_elem t)) x
-> is_element_of (circle_op_2(last_elem t)) (conc_ex x i)))
-> is_element_of (circle_op_2((last_elem (t)))) 
(conc_ex  (execute_tree_list (front t)) i).
Proof. intros. apply set_property_2 in H. apply H. Qed. 

Theorem P3_and_IH:
forall (t: list SE_tree),
is_element_of
        (circle_op_2
           ((second_last_elem t)))
        (execute_tree_list (front t))
/\
is_subset
(circle_op_2 (second_last_elem t))
(circle_op_1 (last_elem t))
->
is_element_of
(circle_op_1 (last_elem t))
(execute_tree_list (front t)).
Proof. intros. apply set_property_1 in H. apply H. Qed. 

Theorem P2_and_etl_imp:
forall (t : list SE_tree),
(is_element_of 
(circle_op_2 (last_elem t))
(execute_tree_list t))
/\
(is_subset 
(circle_op_2 ( (last_elem t)))
Error_States)
->
is_element_of 
Error_States
(execute_tree_list t).
Proof. intros. apply set_property_1 in H. apply H. Qed.

(*Theorem P2_and_etl_imp_ind_step:
forall (t : list SE_tree),
(is_element_of 
(circle_op_2 ((last_elem t)))
(execute_tree_list t))
/\
(is_subset 
(circle_op_2 ((last_elem t)))
 (circle_op_1 ((second_last_elem t))))
/\
((intersection
(circle_op_2 ((last_elem t)))
 (circle_op_1 (second_last_elem t)))
<> empty_set
)
->
is_element_of
 (circle_op_1  (second_last_elem t))
(execute_tree_list t).
Proof. intros. apply set_property_1 in H. apply H. Qed.*)



(*** HELPER THEOREMS ***)

Theorem prefix_not_nil:
forall (t l : list SE_tree),
is_prefix l t -> t <> nil.
Proof. intros. destruct t. 
* destruct l. 
  simpl in H. contradiction. 
  simpl in H. destruct H. contradiction.
* induction l.
  simpl in H. contradiction.
  simpl in H. destruct H. apply H. Qed.


Theorem prefix_def_bw:
forall (t l : list SE_tree) (s : SE_tree),
t <> nil /\ (t = s :: l \/ is_prefix l t) ->
is_prefix (s::l) t.
Proof. intros. simpl. apply H. Qed.



Theorem prefix_not_nil2:
forall (t l : list SE_tree),
is_prefix l t -> l <> nil.
Proof. intros. induction l. 
simpl in H. contradiction.
destruct a. destruct l. simpl in H.
destruct H. inversion H0.
rewrite H1 in H. apply H. 
contradiction.
* simpl in H. destruct H. inversion H0.
** rewrite H1 in H. apply H.
** apply prefix_def_bw in H1. apply IHl in H1.
  apply nil_leaf_elim. apply H1.
* simpl in H. destruct H.
  inversion H0.
** rewrite H1 in H. apply H.
** apply IHl in H1. apply leaf_elim.
    apply H1. Qed.

Theorem no_prefix_of_nil:
forall l : list SE_tree,
is_prefix l nil -> False.
Proof. intros. induction l. 
simpl in H. auto. 
simpl in H. destruct H.
contradiction. Qed.



Theorem prefix_of_self_general:
forall l : list SE_tree,
l <> nil ->
is_prefix l l.
Proof. intros. induction l.
* contradiction.
* simpl;auto. Qed.

Theorem prefix_of_self:
tree_list <> nil ->
is_prefix tree_list tree_list.
Proof. intros. induction tree_list.
* simpl;auto.
* simpl; auto.  Qed.

Theorem first_elem_last_elem:
forall s : SE_tree,
last_elem (s :: nil) = first_elem (s :: nil).
Proof. intros. simpl. auto. Qed. 

(*Axiom prefix_def:
forall (s l : list SE_tree) ( t : SE_tree),
(t :: s) = l /\ s <> nil
-> is_prefix l s.

Axiom prefix_elim:
forall (s l : list SE_tree) ( t : SE_tree),
is_prefix l (t :: s) /\ s <> nil ->
is_prefix l s.
(*Proof. intros. induction l.
* simpl in H. contradiction.
* simpl in H. destruct H. inversion H0.
**  apply prefix_def. *) *)

Theorem first_elem_elim:
forall (s : list SE_tree) ( t : SE_tree),
s <> nil ->
first_elem s = first_elem (t :: s).
Proof. intros. destruct s.
* contradiction.
* simpl; auto. Qed.



Theorem prefix_first_elem :
forall s : list SE_tree,
is_prefix tree_list s 
-> first_elem s = first_elem tree_list.
Proof. intros. destruct s.
apply no_prefix_of_nil in H. contradiction.
destruct s.
* induction tree_list. simpl in H. contradiction. 
  pose H as H1. simpl in H1. destruct H1. inversion H1.
** rewrite H2. auto.
** pose H2 as H3. apply IHl in H3. 
  assert (first_elem l = first_elem (a :: l)).
  apply first_elem_elim. apply prefix_not_nil2 in H2. 
  apply H2. rewrite <- H4. apply H3. 
* induction tree_list.
** simpl in H. contradiction.
** simpl in H. destruct H. inversion H0.
*** rewrite H1. auto.
*** pose H1 as H2. apply prefix_not_nil2 in H2.
    apply IHl in H1. assert (first_elem l = first_elem (a :: l)).
    apply first_elem_elim. apply H2.
    rewrite <- H3. apply H1. Qed.


Theorem basecase:
forall s : SE_tree,
(is_prefix tree_list (s :: nil)) ->
is_element_of (circle_op_2 ((last_elem (s :: nil))))
  (execute_tree_list (s :: nil)).
Proof. intros. apply P1_and_circle_op_prop. split.
*  rewrite first_elem_last_elem. 
apply prefix_first_elem in H. rewrite H.
  apply Prop1. 
* unfold last_elem. 
apply circle_op_property. Qed.

Theorem s_l_e_rewrite :
forall (s s0 : SE_tree) (t : list SE_tree),
second_last_elem (s :: s0 :: t)  = last_elem (s0 :: t).
Proof. intros. simpl; auto. Qed.

Theorem front_rewrite : 
forall (s s0 : SE_tree) (t : list SE_tree), 
front (s :: s0 :: t) = (s0 :: t).
Proof. intros. simpl; auto. Qed.

Theorem sl_nil : 
(is_prefix tree_list nil -> False).
Proof. intros. apply no_prefix_of_nil in H.
 apply H. Qed.

Theorem sl_elim:
forall (s s0 : SE_tree) (t : list SE_tree), 
is_prefix  tree_list (s0 :: s :: t) /\ (s :: t) <> nil
->
is_prefix  tree_list (s :: t).
Proof. intros.  destruct H. induction tree_list.
* simpl in H. contradiction.
* simpl in H. destruct H. inversion H1.
** rewrite <- H2. simpl. split. apply H0.
right. split. apply H0. left. auto.
** apply IHl in H2. simpl. split. apply H0.
right. apply H2. Qed.




Theorem in_list_elim2:
forall (s a : SE_tree) (l : list SE_tree), 
 in_list l s -> in_list (a::l) s.
Proof. intros. induction l.
simpl in H. contradiction.
simpl in H. inversion H.
** simpl. right. left. apply H0.
** simpl. right. right. apply H0. Qed.

Theorem middle_in_list: 
forall (s a : SE_tree) (t : list SE_tree),
is_prefix tree_list (a :: s :: t) ->
in_list tree_list s.
Proof. intros. induction tree_list.
* simpl in H. contradiction.
* simpl in H. destruct H. inversion H0.
** rewrite <- H1. simpl;auto.
**  apply IHl in H1. apply in_list_elim2. apply H1. Qed.

Theorem in_list_elim:
forall (s s0 : SE_tree) (t : list SE_tree), 
is_prefix tree_list (s0 :: s :: t)
->
in_list tree_list s0.
Proof. intros. induction tree_list.
* simpl in H. contradiction.
* simpl in H. destruct H. inversion H0.
** rewrite <- H1. simpl;auto.
** apply IHl in H1. apply in_list_elim2. apply H1. Qed.

Theorem in_list_elim3:
forall (s : SE_tree) (t : list SE_tree), 
is_prefix tree_list (s :: t)
->
in_list tree_list s.
Proof. intros. induction tree_list.
* simpl in H. contradiction.
* simpl in H. destruct H. inversion H0.
** rewrite <- H1. simpl;auto.
** apply IHl in H1. apply in_list_elim2. apply H1. Qed.

Theorem not_leaf_prefix:
forall (s : SE_tree) (t : list SE_tree), 
is_prefix tree_list (s :: t) 
->
s <> nilleaf.
Proof. intros. 
apply in_list_elim3 in H.
apply no_leaf_requirement in H. apply H. Qed.

Theorem not_nil_prefix: 
forall (s a : SE_tree) (t : list SE_tree),
is_prefix tree_list (a :: s :: t) ->
( s :: t) <> nil.
Proof. intros. pose H as H1.
apply middle_in_list in H1.
apply no_leaf_requirement in H1.
apply non_nil_elem_in_list. apply H1. Qed.

(*Theorem list_size_nil_elim:
forall (x : SE_tree) (t : list SE_tree),
list_size (x :: nilleaf :: t) = list_size ( x :: t).
Proof. intros. destruct x.
* simpl;auto. simpl;auto.

Theorem list_size_middle_elim:
forall (x y : SE_tree) (t l : list SE_tree),
list_size (x :: t) = list_size l + 1
-> 
list_size (x :: y :: t) = list_size (y :: l) + 1.
Proof. intros. destruct y.
* simpl. simpl in H. *)



(*Theorem list_size_ind: 
forall (s : SE_tree) (t : list SE_tree),
s <> nilleaf ->
list_size ( s :: t) = (list_size t) + 1.
Proof. intros. destruct s.
* contradiction.
* induction t. 
** simpl;auto.
** apply IHt. Qed.*)

Theorem not_nil_size: 
forall (s : SE_tree) (t : list SE_tree),
list_size ( s :: t) > 0.
Proof. intros. induction t.
* simpl;auto.
* simpl;auto. Qed.

Theorem list_size_prefix:
forall (s : SE_tree) (t : list SE_tree), 
is_prefix  tree_list (s :: t) 
->
list_size (s :: t) > 0.
Proof. intros. apply not_nil_size. Qed.

Theorem c_i_o_elim1 :
forall (a b c: SE_tree) (l : list SE_tree),
consecutive_in_order a b l
-> consecutive_in_order a b (c :: l).
Proof. intros. destruct l. 
* simpl in H. contradiction.
* simpl in H. inversion H.
** simpl. right. left. apply H0.
** simpl. right. right. apply H0. Qed.


Theorem c_i_o_elim :
forall (a b : SE_tree) (t l : list SE_tree),
is_prefix  l (a :: b :: t) ->
consecutive_in_order a b l.
Proof. intros. induction l.
* simpl in H. contradiction.
* simpl in H. destruct H. inversion H0.
** rewrite <- H1. simpl;auto.
** apply IHl in H1.  apply c_i_o_elim1. apply H1. Qed.



(*** MAIN PROOF***)

Theorem etl:
forall t : list SE_tree,
is_prefix tree_list t ->
is_element_of 
  (circle_op_2((last_elem t))) 
  (execute_tree_list t).
Proof. intros. induction t. 
- apply sl_nil in H. contradiction.
- destruct t. 
* apply basecase. apply H.
* rewrite etl_1_step.
** apply P1_and_circle_op_prop_ind_step. split.
*** apply P3_and_IH. split.
+ rewrite front_rewrite. rewrite s_l_e_rewrite. apply IHt.
  pose H as H1. apply not_nil_prefix in H1.
  assert (is_prefix tree_list (a :: s :: t) /\ (s :: t) <> nil).
  split. apply H. apply H1.
  apply sl_elim in H0. apply H0.
+ unfold last_elem.
  pose Prop3 as P3. unfold trees_connect in P3.
  apply P3. simpl. pose H as H1. 
  apply c_i_o_elim in H1. apply H1.
*** apply circle_op_property. 
** split. apply list_size_prefix.
  pose H as H1. apply not_nil_prefix in H1.
  assert (is_prefix tree_list (a :: s :: t) /\ (s :: t) <> nil).
  split. apply H. apply H1.
   apply sl_elim in H0. apply H0.
   split. apply list_size_prefix. apply H.
   apply not_leaf_prefix in H. apply H. Qed.


Theorem sufficiency: 
is_element_of Error_States (execute_tree_list tree_list).
Proof. intros. 
apply P2_and_etl_imp.
split. apply etl. auto. apply prefix_of_self. apply non_empty.
apply Prop2'. Qed.

End SERecurs.
