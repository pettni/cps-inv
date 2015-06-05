case_nr = 3;  % should be 3 or 4
plot_verification = 0; % show verification plots
plot_paper = 1;

tau_min = 1;
tau_des = 1.4;
v_des = 27;
delta = 1;

if case_nr == 3
	con = constants_benign;
elseif case_nr == 4
	con = constants_aggressive;
end	

%%%% Create dynamics

dyn = get_dyn1(con);
pwadyn = get_dyn2(con);

%%%% Specify specification sets

%Safe set
VH = pwadyn.domain;

M1 = intersect(VH, Polyhedron('H', [0 1 0 v_des*tau_des]))
G1 = intersect(VH, Polyhedron('H', [tau_des -1 0 0; 1 0 0 v_des]));

M2 = intersect(VH, Polyhedron('H', [0 -1 0 -v_des*tau_des]))
G2 = intersect(VH, Polyhedron('H', [1 0 0 v_des]));

S = Polyhedron('H', [tau_min -1 0 0])

%%%%%%%%%%%%%%%%%%%%%
%%%% ITERATION 0 %%%%
%%%%%%%%%%%%%%%%%%%%%

C1 = M1;
C2 = M2;

ALL = merge_in(C1, C2);

if plot_verification
	figure(1); clf; hold on

	plot(M1, 'alpha', 0.1, 'color', 'green')
	plot(M2, 'alpha', 0.1, 'color', 'blue')
	plot(G1, 'alpha', 0.5, 'color', 'green')
	plot(G2, 'alpha', 0.5, 'color', 'blue')
end

%%%%%%%%%%%%%%%%%%%%%
%%%% ITERATION 1 %%%%
%%%%%%%%%%%%%%%%%%%%%

% for C1
disp('Iteration 1, cinv set 1')
Inv1_outer = intersect(S, intersect(G1, ALL));
[~, Inv1] = in_out_cinv(dyn, pwadyn, Inv1_outer);

disp('Iteration 1, Reach set 1-inv')
% Can reach Inv1 iff we can reach Inv1(1)
C1_1 = pre_pwa(pwadyn, Inv1(1), intersect(S, ALL));
C1_1 = intersect(C1_1, M1);

disp('Iteration 1, Reach set 1-C2')
C1_2 = pre_pwa(pwadyn, C2, intersect(S, ALL));
C1_2 = intersect(C1_2, M1);

if plot_verification
	figure(2); clf; hold on
	plot(intersect(Inv1, M1), 'color', 'blue', 'alpha', 0.01);
	plot(C1_1, 'color', 'red', 'alpha', 0.01);
	plot(C1_2, 'color', 'green', 'alpha', 0.01);
	Can verify that Reach(C2) \subset Reach(Inv1)!
end

C1 = C1_1;

disp('Iteration 1, Inv set 2')
Inv2_outer = intersect(S, intersect(G2, ALL));
[~, Inv2] = in_out_cinv(dyn, pwadyn, Inv2_outer);

if plot_verification
	figure(3); clf; hold on
	plot(intersect(Inv2, Polyhedron('H', [0 1 0 200])), 'color', 'blue', 'alpha', 0.01)
	plot(intersect(C1, Polyhedron('H', [0 1 0 200])), 'color', 'red', 'alpha', 0.01)
	Disregard C1, it is "almost" contained in Inv2
end

disp('Iteration 1, Reach set 2-inv')
C2_1 = pre_pwa(pwadyn, Inv2(1), intersect(S, ALL));
C2_1 = intersect(C2_1, M2)
C2 = C2_1;

if plot_verification
	figure(4); clf; hold on
	plot(C1, 'color', 'blue', 'alpha', 0.01)
	plot(intersect(C2, Polyhedron('H', [0 1 0 200])), 'color', 'red', 'alpha', 0.01)
end

%%%%%%%%%%%%%%%%%%%%%
%%%% ITERATION 2 %%%%
%%%%%%%%%%%%%%%%%%%%%

% Since we disregarded from where C2 could be reached, we have that
%  C1 \subset M1 \cap Reach( Inv ( G1 \cap (C1 \cup C2) \cup C2 ) )
%
% same holds for C2 -> convergence

if plot_paper
	run_plotpaper
end