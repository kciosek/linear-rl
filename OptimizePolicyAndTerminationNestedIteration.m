classdef OptimizePolicyAndTerminationNestedIteration < handle        
    % This filed defines a modification of the value iteration algorithm.
    % The optimization is done in a nested way -- first, it is determined 
    % whether to terminate in a given state, then the action is chosen.
    
    % See constructor for explanation of what the properties mean.
    properties
      useModels;
      noTermFirst,
      As,
      Gs,
      Is,
      fIs,
    end
    
    methods
        function obj = OptimizePolicyAndTerminationNestedIteration(...
                                                    As,Gs,useModels,...
                                                    noTermFirst,Is)
        % This function initializes the object for doing the actual
        % iteration. There are the following parameters.
        % As - a cell array contating the action models
        % Gs - a cell array contating the subgoal vectors.
        % useModels - a boolean variables specifing is the allowed action
        % set should consist only of the base actions (when it is false),
        % or wether other models from the previous iteration should also be
        % used (when it is true).
        % noTermFirst - specifies if the first model is allowed to
        % terminate. True means it cannot. This setting should be used for
        % the overall goal of maximizing the total reward.
        % Is - the cell array containing the initiation sets.
            
            %If the noTermFirst parameter is not present, initialize it to
            %not terminate.
            if nargin < 4
                noTermFirst = true;
            end
            
            %If no initiation set is given, we assume that a model can be
            %used from any state.
            if nargin < 5
                Is = makeFullIs(length(As),size(As{1},1));
            end
                                                    
            obj.useModels = useModels;
            obj.As = As;
            obj.Gs = Gs;
            obj.noTermFirst = noTermFirst;
            obj.Is = Is;
            
            %The fIs property contains the indices of those rows of the
            %model which correspond to the values of true in the initiation
            %set. They are the rows we take into account when doing the
            %iteration.
            obj.fIs = cellfun(@find, Is,'UniformOutput',false);
        end
        
        function Msnew = iterate(obj,Ms)            
            % We preallocate memory for the models Msnew that will be the
            % outcome of our iteration.
            Msnew = cell(length(Ms),1);
            
            % cmodels is the set (cell array) of models that we will choose
            % from in the iteration.
            if obj.useModels
                cmodels = [obj.As; Ms];
            else
                cmodels = obj.As;
            end
            
            % For reasons of speed, it is faster to work with transposed
            % models.
            cmodelst = cellfun(@(m) m',cmodels,'UniformOutput',false);
            
            %We iterate over all the models.
            for i=1:length(Ms)
                %Store the computed new model. We work with transposes
                %because it is faster.
                Msnew{i} = obj.iterateSingleModel(Ms,i,cmodelst)';
            end
        end
        
        function Mnewt = iterateSingleModel(obj,Ms,i,cmodelst)
        % This function computes one iteration for one model (i.e. the one
        % with index i) of the set we are considering.
            
            % Preallocate memory of our resulting model. For reasons of
            % speed, we work with transposed models.
            Mnewt = Ms{i}';

            % First, we whether or not to terminate in each state.
            Ebetat = obj.determineTermination(Mnewt,Ms,i);

            % The vector that we will be multiplying rows from our
            % models with
            cb = obj.Gs{i}' * Ebetat;

            % Permultiply the action models with Ebetat in one step.
            ebetatcmodelst = cellfun(@(m) Ebetat*m ,cmodelst,...
                'UniformOutput',false);

            % This vector will store the values associated with taking
            % a particulat action in a particualr state.
            val = -realmax * ones(size(obj.As{1},1),1);

            % Iterate over all actions and models in cmodels.
            for ai = 1:length(cmodelst)
                %Set span to be the initiatioon set of the surrent 
                %model. If we do not have an initiation set, set it to
                %all rows.
                if ai <= length(obj.As)
                    span = obj.fIs{ai}(2:end);
                else
                    span = 2:size(obj.As{1},1);
                end

                %Iterate over all rows in the initation set
                for j=1:length(span)
                    r = span(j);
                    nvt = cb * cmodelst{ai}(:,r);
                    if nvt > val(r)
                        val(r) = nvt;
                        Mnewt(:,r) = ebetatcmodelst{ai}(:,r);
                    end                                    
                end
            end                                
        end
        
        
        function Ebetat = determineTermination(obj,Mnewt,Ms,i)
        % The model Ebetat has columns from the identity matrix for
        % states in which we terminate and columns from Mnewt for
        % states where we do not.
        % We work with transposed model which means that we use columns
        % instead of rows.            
        % If the parmater is set to never terminate for the first
        % subgoal, we just return Mnewt.            
            gst = obj.Gs{i}';
        
            if i == 1 && obj.noTermFirst 
                Ebetat = Mnewt;                    
            else
                Ebetat = obj.sparseEye(size(Ms{i},1));
                for r=2:size(Ms{i},1)
                    valTerminate = obj.Gs{i}(r);
                    valContinue = gst * Mnewt(:,r);

                    % If it pays not to terminate, copy the appropriate
                    % column from Mnewt.
                    if valTerminate < valContinue                            
                        Ebetat(:,r) = Mnewt(:,r);
                    end
                end
            end
        end
        
        function se = sparseEye(~,size)
        % This function generates the indentity matrix of size given
        % by the paramter. Sparse matrices are used for large sizes.
            if (size > 1000)
                se = sparse(1:size,1:size,ones(1,size),size,size);
            else
                se = eye(size);
            end
        end
    end
end

