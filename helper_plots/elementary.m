classdef elementary
    properties
        n1 {mustBeFinite, mustBeLessThanOrEqual(n1, 0)}
        n2 {mustBeGreaterThanOrEqual(n2, 0)} 
        n0 {mustBeNumeric}
    end
    methods
        function r = elementary(m_n1, m_n2, m_n0)
            if nargin == 3
                r.n1 = m_n1;
                r.n2 = m_n2;
                r.n0 = m_n0;
            end
        end
        function [d, n] = impseq(r)
            n = r.n1:r.n2;
            d = (n - r.n0) == 0;
        end
        function [u, n] = unit_set(r)
            n = r.n1:r.n2;
            u = (n - r.n0) >= 0;
        end
    end
end