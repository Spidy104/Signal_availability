classdef signal_plotting
    %Signal plotting Basic Plotting functions implemented in matlab
    % functions like addition, multiplication, shifting, etc.

    properties
        x1, n1 {mustBeFinite mustBeNonNan}
    end

    methods
        function obj = signal_plotting(m_x1_, m_n1_)
             %Construct an instance of this class  
            obj.x1 = m_x1_;
            obj.n1 = m_n1_;
        end

        function [y, n] = sigadd(obj, m_x2, m_n2)
            %METHOD1 Summary of this method goes here
            %   addition of two signals
            arguments
                obj, m_x2, m_n2 {mustBeNonempty mustBeNonNan}
            end
            n = min(min(obj.n1), min(m_n2)):max(max(obj.n1), max(m_n2));
            y1 = zeros(1, length(n));
            y2 = y1;
            y1((n >= min(obj.n1)) & (n <= max(obj.n1))) = obj.x1;
            y2((n >= min(m_n2)) & (n <= max(m_n2))) = m_x2;
            y = y1+y2;
        end
        function [y, n] = sigmult(obj, m_x2, m_n2)
            %METHOD1 Summary of this method goes here
            %   addition of two signals
            arguments
                obj, m_x2, m_n2
            end
            n = min(min(obj.n1), min(m_n2)):max(max(obj.n1), max(m_n2));
            y1 = zeros(1, length(n));
            y2 = y1;
            y1((n >= min(obj.n1)) & (n <= max(obj.n1))) = obj.x1;
            y2((n >= min(m_n2)) & (n <= max(m_n2))) = m_x2;
            y = y1.* y2;
        end
        function [y, n] = sigshift(obj, m_k)
            n = obj.n1+m_k;
            y = obj.x1;
        end
        function plot(obj)
            figure(1);
            stem(obj.n1, obj.x1);
            xlabel('Samples');
            ylabel('Amplitude');
            grid;
        end
        function [y, n] = sigfold(obj)
            y = fliplr(obj.x1);
            n = -fliplr(obj.n1);
        end
    end
end